--Rousing Hydradrive Monarch
--Made by Beetron-1 Beetletop
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x577)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,4,4,s.spcheck)
	--place
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.ctcon)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
    --Hardest part
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_FORCE_NORMAL_SUMMON_POSITION)
	e2:SetTargetRange(1,1)
	e2:SetValue(POS_FACEUP_ATTACK)
	e2:SetTarget(s.distg)
	c:RegisterEffect(e2)
    --Hardest part
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
	e3:SetTargetRange(1,1)
	e3:SetValue(POS_FACEUP_ATTACK)
	e3:SetTarget(s.distg)
	c:RegisterEffect(e3)
    --Send to GY
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)	
	e4:SetHintTiming(0,TIMING_MAIN_END)
	e4:SetCondition(s.condition)
	e4:SetCost(s.cost)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
s.roll_dice=true
function s.matfilter(c,scard,sumtype,tp)
	return c:IsType(TYPE_LINK) and c:IsSetCard(0x577,scard,sumtype,tp)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonLocation()==LOCATION_EXTRA
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		c:AddCounter(0x577,4)
	      end
			if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_ATTRIBUTE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetValue(0xe)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.earth_filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH)
end
function s.wind_filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND)
end
function s.water_filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
function s.fire_filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.light_filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.dark_filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x577,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x577,1,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
   if chk==0 then return true end
   Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,1,tp)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,chk)
      local dice=Duel.TossDice(tp,1)
	local g1=Duel.GetMatchingGroup(s.earth_filter,tp,0,LOCATION_MZONE,nil)
	local g2=Duel.GetMatchingGroup(s.water_filter,tp,0,LOCATION_MZONE,nil)
	local g3=Duel.GetMatchingGroup(s.fire_filter,tp,0,LOCATION_MZONE,nil)
	local g4=Duel.GetMatchingGroup(s.wind_filter,tp,0,LOCATION_MZONE,nil)
	local g5=Duel.GetMatchingGroup(s.light_filter,tp,0,LOCATION_MZONE,nil)
	local g6=Duel.GetMatchingGroup(s.dark_filter,tp,0,LOCATION_MZONE,nil)
	if dice==1 and #g1>0 then
	Duel.SendtoGrave(g1,REASON_EFFECT)
	local og=Duel.GetOperatedGroup()
	local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
	Duel.BreakEffect()
	Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	elseif dice==2 and #g2>0 then
	Duel.SendtoGrave(g2,REASON_EFFECT)
	local og=Duel.GetOperatedGroup()
	local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
	Duel.BreakEffect()
	Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	elseif dice==3 and #g3>0 then
	Duel.SendtoGrave(g3,REASON_EFFECT)
	local og=Duel.GetOperatedGroup()
	local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
	Duel.BreakEffect()
	Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	elseif dice==4 and #g4>0 then
	Duel.SendtoGrave(g4,REASON_EFFECT)
	local og=Duel.GetOperatedGroup()
	local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
	Duel.BreakEffect()
	Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	elseif dice==5 and #g5>0 then
	Duel.SendtoGrave(g5,REASON_EFFECT)
	local og=Duel.GetOperatedGroup()
	local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
	Duel.BreakEffect()
	Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	elseif dice==6 and #g6>0 then
	Duel.SendtoGrave(g6,REASON_EFFECT)
	local og=Duel.GetOperatedGroup()
	local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
	Duel.BreakEffect()
	Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	end
end
function s.distg(e,c)
	return c:IsAttribute(e:GetHandler():GetAttribute())
end