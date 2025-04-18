--ワナビー！
--Wannabee!
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--During the End Phase, excavate and Set 1 Trap card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE|LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfToGrave)
	e1:SetTarget(s.excvttg)
	e1:SetOperation(s.excvtop)
	c:RegisterEffect(e1)
end
function s.excvttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=5-Duel.GetMatchingGroupCount(nil,tp,0,LOCATION_STZONE,nil)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=ct end
end
function s.setfilter(c)
	return c:IsTrap() and c:IsSSetable()
end
function s.excvtop(e,tp,eg,ep,ev,re,r,rp)
	local excct=5-Duel.GetMatchingGroupCount(nil,tp,0,LOCATION_STZONE,nil)
	Duel.ConfirmDecktop(tp,excct)
	local g=Duel.GetDecktopGroup(tp,excct)
	if #g==0 then return end
	local ct=0
	if g:IsExists(s.setfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.DisableShuffleCheck()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local tc=g:FilterSelect(tp,s.setfilter,1,1,nil):GetFirst()
		if tc and Duel.SSet(tp,tc) then
			local fid=tc:GetFieldID()
			tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,2,fid)
			--Send it to the GY during the next End Phase
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetCondition(s.tgcon)
			e1:SetOperation(s.tgop)
			e1:SetLabel(Duel.GetTurnCount(),fid)
			e1:SetLabelObject(tc)
			e1:SetReset(RESET_PHASE|PHASE_END,2)
			Duel.RegisterEffect(e1,tp)
		end
		ct=1
	end
	local ac=#g-ct
	if ac>0 then
		Duel.MoveToDeckBottom(ac,tp)
		Duel.SortDeckbottom(tp,tp,ac)
	end
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local turn,fid=e:GetLabel()
	local tc=e:GetLabelObject()
	return Duel.GetTurnCount()~=turn and tc:GetFlagEffectLabel(id)==fid
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(e:GetLabelObject(),REASON_EFFECT)
	e:Reset()
end