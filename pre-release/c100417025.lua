-- アラメシアの儀
-- Rite of Aramesia
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon token
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- Count activated monster effects
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.actfilter)
end
s.listed_names={TOKEN_BRAVE,100417029}
function s.actfilter(re)
	local rc=re:GetHandler()
	return not (re:IsActiveType(TYPE_MONSTER) and rc:IsOnField() and not rc:IsSummonType(SUMMON_TYPE_SPECIAL))
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,TOKEN_BRAVE),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)==0 end
	-- Cannot activate effects of monsters, except Special Summoned monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(_,re) return not s.actfilter(re) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_BRAVE,0,TYPES_TOKEN,2000,2000,4,RACE_FAIRY,ATTRIBUTE_EARTH) 
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.plfilter(c)
	return c:IsCode(100417029) and not c:IsForbidden()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not s.sptg(e,tp,eg,ep,ev,re,r,rp,0) then return end
	local token=Duel.CreateToken(tp,TOKEN_BRAVE)
	if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and not Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,100417029),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK,0,1,nil) 
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if tc then
			Duel.BreakEffect()
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	end
end