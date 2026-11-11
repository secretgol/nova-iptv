package com.iptv.tvbox.ui.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import coil.load
import com.iptv.tvbox.R
import com.iptv.tvbox.data.model.Channel
import com.iptv.tvbox.databinding.ItemChannelBinding
import com.iptv.tvbox.ui.util.FocusHelper

class ChannelAdapter(
    private val onChannelClick: (Channel) -> Unit,
    private val onChannelLongClick: (Channel) -> Boolean
) : ListAdapter<Channel, ChannelAdapter.ChannelViewHolder>(ChannelDiffCallback()) {

    inner class ChannelViewHolder(val binding: ItemChannelBinding) :
        RecyclerView.ViewHolder(binding.root) {

        init {
            FocusHelper.setupTvFocusAnimation(binding.cardChannel, 1.08f)

            binding.cardChannel.setOnClickListener {
                val position = bindingAdapterPosition
                if (position != RecyclerView.NO_POSITION) {
                    onChannelClick(getItem(position))
                }
            }

            binding.cardChannel.setOnLongClickListener {
                val position = bindingAdapterPosition
                if (position != RecyclerView.NO_POSITION) {
                    onChannelLongClick(getItem(position))
                } else {
                    false
                }
            }
        }

        fun bind(channel: Channel) {
            binding.txtChannelNumber.text = channel.channelNum.toString()
            binding.txtChannelName.text = channel.name

            // Favorite star badge
            binding.imgFavorite.visibility = if (channel.isFavorite) View.VISIBLE else View.GONE

            // Channel Logo with Coil
            if (!channel.logoUrl.isNullOrBlank()) {
                binding.imgLogo.load(channel.logoUrl) {
                    crossfade(true)
                    placeholder(R.drawable.ic_tv)
                    error(R.drawable.ic_tv)
                }
            } else {
                binding.imgLogo.setImageResource(R.drawable.ic_tv)
            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ChannelViewHolder {
        val binding = ItemChannelBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        return ChannelViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ChannelViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    class ChannelDiffCallback : DiffUtil.ItemCallback<Channel>() {
        override fun areItemsTheSame(oldItem: Channel, newItem: Channel): Boolean {
            return oldItem.id == newItem.id
        }

        override fun areContentsTheSame(oldItem: Channel, newItem: Channel): Boolean {
            return oldItem == newItem && oldItem.isFavorite == newItem.isFavorite
        }
    }
}
