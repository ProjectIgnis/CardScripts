function Duel.GiveUpDraw(e,OathCheck)
	local dt=Duel.GetDrawCount(tp)
		if dt~=0 then
			_replace_count=0
			_replace_max=dt
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			if OathCheck then
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
			else
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			end
			e1:SetCode(EFFECT_DRAW_COUNT)
			e1:SetTargetRange(1,0)
			e1:SetReset(RESET_PHASE+PHASE_DRAW)
			e1:SetValue(0)
			Duel.RegisterEffect(e1,tp)
		end
	_GiveUpDrawFlag=e
end
function Duel.CheckGiveUpDraw(e)
	return _GiveUpDrawFlag==e
end
