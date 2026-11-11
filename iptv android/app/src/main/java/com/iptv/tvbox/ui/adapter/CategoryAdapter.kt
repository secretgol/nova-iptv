package com.iptv.tvbox.ui.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.iptv.tvbox.R
import com.iptv.tvbox.data.model.Category
import com.iptv.tvbox.databinding.ItemCategoryBinding
import com.iptv.tvbox.ui.util.FocusHelper

class CategoryAdapter(
    private var categories: List<Category>,
    private val onCategorySelected: (Category) -> Unit
) : RecyclerView.Adapter<CategoryAdapter.CategoryViewHolder>() {

    private var selectedIndex = 0

    inner class CategoryViewHolder(val binding: ItemCategoryBinding) :
        RecyclerView.ViewHolder(binding.root) {

        init {
            FocusHelper.setupTvFocusAnimation(binding.layoutCategory, 1.05f)

            binding.layoutCategory.setOnClickListener {
                val position = bindingAdapterPosition
                if (position != RecyclerView.NO_POSITION) {
                    selectCategory(position)
                }
            }

            // Also support selection on remote focus if preferred, or on OK click
            binding.layoutCategory.setOnFocusChangeListener { _, hasFocus ->
                if (hasFocus) {
                    binding.layoutCategory.scaleX = 1.05f
                    binding.layoutCategory.scaleY = 1.05f
                } else {
                    binding.layoutCategory.scaleX = 1.0f
                    binding.layoutCategory.scaleY = 1.0f
                }
            }
        }

        fun bind(category: Category, isSelected: Boolean) {
            binding.txtCategoryName.text = category.name
            binding.txtCategoryCount.text = category.count.toString()
            binding.layoutCategory.isSelected = isSelected
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): CategoryViewHolder {
        val binding = ItemCategoryBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        return CategoryViewHolder(binding)
    }

    override fun onBindViewHolder(holder: CategoryViewHolder, position: Int) {
        val category = categories[position]
        holder.bind(category, position == selectedIndex)
    }

    override fun getItemCount(): Int = categories.size

    fun updateCategories(newCategories: List<Category>) {
        this.categories = newCategories
        if (selectedIndex >= categories.size) {
            selectedIndex = 0
        }
        notifyDataSetChanged()
    }

    fun selectCategory(position: Int) {
        if (position in categories.indices) {
            val prevIndex = selectedIndex
            selectedIndex = position
            notifyItemChanged(prevIndex)
            notifyItemChanged(selectedIndex)
            onCategorySelected(categories[selectedIndex])
        }
    }

    fun selectCategoryById(id: String) {
        val idx = categories.indexOfFirst { it.id == id }
        if (idx != -1) {
            selectCategory(idx)
        }
    }
}
