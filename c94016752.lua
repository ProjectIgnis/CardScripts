--深淵の宣告者
--Herald of the Abyss
--Scripted by ahtelel
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1500) end
	Duel.PayLPCost(tp,1500)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:SetLabel(rc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	local at=Duel.AnnounceAttribute(tp,1,0xffff)
	Duel.SetTargetParam(at)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_MZONE)
end
function s.filter(c,rc,at)
	return c:IsFaceup() and c:IsRace(rc) and c:IsAttribute(at) and c:IsAbleToGrave()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()	
	local rc=e:GetLabel()
	local at=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local g=Duel.SelectMatchingCard(1-tp,s.filter,1-tp,LOCATION_MZONE,0,1,1,nil,rc,at)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_RULE)
		if g:GetFirst():IsLocation(LOCATION_GRAVE) then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e2:SetCode(EFFECT_CANNOT_ACTIVATE)
			e2:SetTargetRange(0,1)
			e2:SetValue(s.aclimit)
			e2:SetLabelObject(g:GetFirst())
			e2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2,tp)
		end
	end
end
function s.aclimit(e,re,tp)
	local tc=e:GetLabelObject()
	return re:GetHandler():IsCode(tc:GetCode()) and re:IsActiveType(TYPE_MONSTER)
end