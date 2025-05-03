--灰燼竜バスタード
--Titaniklad the Ash Dragon
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: "Fallen of Albaz" + 1 monster with 2500 or more ATK
	Fusion.AddProcMix(c,true,true,CARD_ALBAZ,aux.FilterBoolFunctionEx(Card.IsAttackAbove,2500))
	--Gains ATK equal to the combined original Levels of the monsters used for its Fusion Summon x 100
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.valcheck)
	c:RegisterEffect(e1)
	--After this card is Fusion Summoned, for the rest of this turn, it is unaffected by the activated effects of any other monsters Special Summoned from the Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	--Add to your hand, or Special Summon, 1 "Dogmatika" monster or 1 "Fallen of Albaz" from your Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function(e) local c=e:GetHandler() return c:GetTurnID()==Duel.GetTurnCount() and not c:IsReason(REASON_RETURN) end)
	e3:SetTarget(s.thsptg)
	e3:SetOperation(s.thspop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_ALBAZ}
s.listed_series={SET_DOGMATIKA}
function s.valcheck(e,c)
	local atk=c:GetMaterial():GetSum(Card.GetOriginalLevel)*100
	if atk==0 then return end
	--Gains ATK equal to the combined original Levels of the monsters used for its Fusion Summon x 100
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE&~RESET_TOFIELD)
	c:RegisterEffect(e1)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFusionSummoned() then return end
	--After this card is Fusion Summoned, for the rest of this turn, it is unaffected by the activated effects of any other monsters Special Summoned from the Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(s.immval)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e1)
end
function s.immval(e,te)
	local tc=te:GetHandler()
	local trig_loc,trig_sum_loc=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SUMMON_LOCATION)
	if not (te:IsActivated() and te:IsMonsterEffect() and trig_loc==LOCATION_MZONE and tc~=e:GetHandler()) then return false end
	if not Duel.IsChainSolving() or (tc:IsRelateToEffect(te) and tc:IsFaceup() and tc:IsLocation(trig_loc)) then
		return tc:IsSummonLocation(LOCATION_EXTRA)
	else
		return trig_sum_loc&LOCATION_EXTRA>0
	end
end
function s.thspfilter(c,e,tp,mmz_chk)
	return (c:IsSetCard(SET_DOGMATIKA) or c:IsCode(CARD_ALBAZ)) and c:IsMonster() and (c:IsAbleToHand()
		or (mmz_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_DECK,0,1,nil,e,tp,Duel.GetLocationCount(tp,LOCATION_MZONE)>0) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local sc=Duel.SelectMatchingCard(tp,s.thspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,mmz_chk):GetFirst()
	if not sc then return end
	aux.ToHandOrElse(sc,tp,
		function()
			return mmz_chk and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function()
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,3)
	)
end
