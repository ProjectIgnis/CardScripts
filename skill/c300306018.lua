--Ancient Ruler Rises
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,2,false,s.flipcon,s.flipop,1)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabelObject(e)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
s.listed_names={31076103,4081094,78697395,25343280,52550973,89959682}
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(0x5f)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsCode(25343280) end)
	e1:SetValue(s.value)
	Duel.RegisterEffect(e1,tp)
end
--ATK gain functions
function s.pfilter(c)
	return c:IsCode(52550973) or c:IsCode(89959682)
end
function s.value(e,c)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroupCount(s.pfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil) 
	return g*900
end
--Sarcophagus functions
function s.tgfilter(c,tp)
	return c:IsLevel(2) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
end
function s.sfilter(c)
	return c:IsCode(31076103,4081094,78697395) and not c:IsForbidden() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE+LOCATION_DECK))
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 and Duel.SendtoGrave(g,REASON_COST)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.sfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		if #sg>0 then
			Duel.MoveToField(sg:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	end
end