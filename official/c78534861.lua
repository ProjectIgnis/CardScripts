--スケアクロー・クシャトリラ
--Scareclaw Kashtira
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Can attack while in face-up Defense Position
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DEFENSE_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Special Summon this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e2:SetCondition(function() return Duel.IsMainPhase() end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Negate the effects of monsters that battle your "Scareclaw" or "Kashtira" monsters
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(s.distg)
	c:RegisterEffect(e3)
	--Adjust itself to apply the negation effect right away
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetOperation(function(e) Duel.AdjustInstantly(e:GetHandler()) end)
	c:RegisterEffect(e4)
end
s.listed_series={SET_SCARECLAW,SET_KASHTIRA}
function s.rmfilter(c)
	return c:IsSetCard({SET_SCARECLAW,SET_KASHTIRA}) and c:IsAbleToRemove()
		and (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c,true))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_MZONE,0,1,c)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_MZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function s.distg(e,c)
	local fid=e:GetHandler():GetFieldID()
	for _,label in ipairs({c:GetFlagEffectLabel(id)}) do
		if fid==label then return true end
	end
	local bc=c:GetBattleTarget()
	if c:IsRelateToBattle() and bc and bc:IsControler(e:GetHandlerPlayer())
		and bc:IsFaceup() and bc:IsSetCard({SET_SCARECLAW,SET_KASHTIRA}) then
		c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1,fid)
		return true
	end
	return false
end