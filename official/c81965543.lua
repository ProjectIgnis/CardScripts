--JP name
--Distrust Paranoia
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Take control of all your opponent's monsters in this card's column
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--If this Set card in its owner's control has left the field by an opponent's effect, and is now in the GY or banished: You can Special Summon this card as an Effect Monster (Fiend/DARK/Level 10/ATK 4000/DEF 4000) with the following effect (this card is NOT treated as a Trap) 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--● Unaffected by your opponent's card effects activated in the same column
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(function(e)
		return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+1)
	end)
	e3:SetValue(function(e,te)
		return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated() and e:GetHandler():IsColumn(te:GetCardSequence(),te:GetCardControler(),te:GetCardLocation())
	end)
	c:RegisterEffect(e3)
end
function s.ctrlfilter(c,tp)
	return c:IsControler(1-tp) and c:IsLocation(LOCATION_MZONE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local colg=c:GetColumnGroup():Match(s.ctrlfilter,nil,tp)
	local ctrl_colg=colg:Filter(Card.IsAbleToChangeControler,nil)
	local ctrl_colg_count=#ctrl_colg
	if chk==0 then return #colg>0 and ctrl_colg_count==#colg and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)>=ctrl_colg_count end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,ctrl_colg,ctrl_colg_count,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local colg=c:GetColumnGroup():Match(s.ctrlfilter,nil,tp)
	local ctrl_colg=colg:Filter(Card.IsAbleToChangeControler,nil)
	local ctrl_colg_count=#ctrl_colg
	local mzone_count=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)
	if ctrl_colg_count>0 and ctrl_colg_count==#colg and (mzone_count<=0 or mzone_count>=ctrl_colg_count) then
		Duel.GetControl(ctrl_colg,tp)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEDOWN) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) and rp==1-tp
		and c:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPE_MONSTER|TYPE_EFFECT,4000,4000,10,RACE_FIEND,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPE_MONSTER|TYPE_EFFECT,4000,4000,10,RACE_FIEND,ATTRIBUTE_DARK) then
		c:AddMonsterAttribute(TYPE_EFFECT)
		c:AssumeProperty(ASSUME_RACE,RACE_FIEND)
		Duel.SpecialSummonStep(c,1,tp,tp,true,false,POS_FACEUP)
		c:AddMonsterAttributeComplete()
		Duel.SpecialSummonComplete()
	end
end