-- クリムゾン・ブレード・ドラゴン
--Crimson Blade Dragon
local s,id=GetID()
local CARD_CRIMSON_BLADER=80321197
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 "Resonator" Tuner + 1+ non-Tuner monsters
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_RESONATOR),1,1,Synchro.NonTuner(nil),1,99)
	--Take 1 Level 8 or higher monster from your Deck or GY that cannot be Normal Summoned/Set, and either Special Summon it (but negate its effects) or add it to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsSynchroSummoned() end)
	e1:SetTarget(s.thsptg)
	e1:SetOperation(s.thspop)
	c:RegisterEffect(e1)
	--Destroy that monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_CRIMSON_BLADER}
s.listed_series={SET_RESONATOR}
function s.thspfilter(c,e,tp,mmz_chk)
	return c:IsLevelAbove(8) and not c:IsSummonableCard() and (c:IsAbleToHand()
		or (mmz_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp,Duel.GetLocationCount(tp,LOCATION_MZONE)>0) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thspfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp,mmz_chk):GetFirst()
	if not sc then return end
	aux.ToHandOrElse(sc,tp,
		function()
			return mmz_chk and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function()
			if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
				--Negate its effects
				sc:NegateEffects(e:GetHandler())
			end
			Duel.SpecialSummonComplete()
		end,
		aux.Stringid(id,2)
	)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc and bc:IsFaceup() and bc:IsLevelAbove(5) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		Duel.Destroy(bc,REASON_EFFECT)
	end
end