-- 宝玉の加護
-- Crystal Protection
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Destroy 1 "Crystal Beast" Monster Card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- Special Summon 1 "Crystal Beast" monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_MOVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={100344117}
s.listed_series={0x1034}
function s.getprops(c)
	return math.max(0,c:GetTextAttack()),math.max(0,c:GetTextDefense()),
		c:GetOriginalLevel(),c:GetOriginalRace(),c:GetOriginalAttribute()
end
function s.desfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsOriginalType(TYPE_MONSTER) and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+100,0x1034,TYPES_TOKEN,s.getprops(c))
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.desfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+100,0x1034,TYPES_TOKEN,s.getprops(tc)) then
		Duel.BreakEffect()
		local token=Duel.CreateToken(tp,id+100)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
			-- Change Type, Attribute, Level, and ATK/DEF
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(tc:GetOriginalRace())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			token:RegisterEffect(e1,true)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e2:SetValue(tc:GetOriginalAttribute())
			token:RegisterEffect(e2,true)
			local e3=e1:Clone()
			e3:SetCode(EFFECT_CHANGE_LEVEL)
			e3:SetValue(tc:GetOriginalLevel())
			token:RegisterEffect(e3,true)
			local e4=e1:Clone()
			e4:SetCode(EFFECT_SET_BASE_ATTACK)
			e4:SetValue(math.max(0,tc:GetTextAttack()))
			token:RegisterEffect(e4,true)
			local e5=e1:Clone()
			e5:SetCode(EFFECT_SET_BASE_DEFENSE)
			e5:SetValue(math.max(0,tc:GetTextDefense()))
			token:RegisterEffect(e5,true)
		end
		Duel.SpecialSummonComplete()
	end
end
function s.spconfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsLocation(LOCATION_SZONE) and not c:IsPreviousLocation(LOCATION_SZONE)
		and c:IsControler(tp) and c:GetSequence()<5
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(s.spconfilter,1,nil,tp)
end
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsOriginalType(TYPE_MONSTER)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end