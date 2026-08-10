--葬嶺異解△ヴェルヘイム
--Burial Summit Xenovader△ Helheim
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--During the Main Phase (Quick Effect): You can reveal this card in your hand; banish it (face-down), and if you do, Special Summon 1 of your face-down banished "Xenovader△" monsters, except a Level 6 monster. You can only use this effect of "Burial Summit Xenovader△ Helheim" once per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsMainPhase()
	end)
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(s.selfbantg)
	e1:SetOperation(s.selfbanop)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e1)
	--If this card is Normal or Special Summoned: Banish (face-down) the top 6 cards of your Deck
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_REMOVE)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2a:SetCode(EVENT_SUMMON_SUCCESS)
	e2a:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,6,tp,LOCATION_DECK)
	end)
	e2a:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetDecktopGroup(tp,6)
		if #g>0 then
			Duel.DisableShuffleCheck()
			Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		end
	end)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
	--Other "Xenovader△" cards you control cannot be destroyed by your opponent's card effects, also your opponent cannot target them with card effects
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_FIELD)
	e3a:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetTargetRange(LOCATION_ONFIELD,0)
	e3a:SetTarget(function(e,c)
		return c:IsSetCard(SET_XENOVADER) and c~=e:GetHandler()
	end)
	e3a:SetValue(aux.indoval)
	c:RegisterEffect(e3a)
	local e3b=e3a:Clone()
	e3b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3b:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3b:SetValue(aux.tgoval)
	c:RegisterEffect(e3b)
end
s.listed_series={SET_XENOVADER}
function s.spfilter(c,e,tp)
	return c:IsFacedown() and c:IsSetCard(SET_XENOVADER) and c:IsMonster() and not c:IsLevel(6)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetOriginalCodeRule())
		-- and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.selfbantg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove(tp,POS_FACEDOWN)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,tp,POS_FACEDOWN)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.selfbanop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)>0 and c:IsLocation(LOCATION_REMOVED) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end