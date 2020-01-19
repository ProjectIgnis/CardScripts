--氷結界の鏡
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_REMOVE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCondition(s.rmcon)
	e1:SetOperation(s.rmop)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local flag=0
	local tc=eg:GetFirst()
	for tc in aux.Next(eg) do
		local ploc=tc:GetPreviousLocation()
		local te=tc:GetReasonEffect()
		if tc:IsReason(REASON_EFFECT) and not tc:IsReason(REASON_REDIRECT) and (ploc&0x1e)~=0 and tc:IsPreviousControler(tp)
			and te:GetOwnerPlayer()==1-tp and te:IsActiveType(TYPE_MONSTER) and te:IsActivated() then
			flag=(flag|ploc)
		end
	end
	e:SetLabel(flag)
	return flag~=0
end
function s.rmfilter(c)
	return c:IsAbleToRemove() and aux.SpElimFilter(c)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	local flag=e:GetLabel()
	if (flag&LOCATION_HAND)~=0 then
		local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
		if #rg>0 then
			local ct=1
			if #rg>1 then ct=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))+1 end
			g:Merge(rg:RandomSelect(tp,ct))
		end
	end
	if (flag&LOCATION_ONFIELD)~=0 then
		local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
		if #rg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			g:Merge(rg:Select(tp,1,2,nil))
		end
	end
	if (flag&LOCATION_GRAVE)~=0 then
		local rg=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,nil)
		if #rg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			g:Merge(rg:Select(tp,1,2,nil))
		end
	end
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
