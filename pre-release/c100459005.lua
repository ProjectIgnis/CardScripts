--機械龍－リボルバー・ドラゴン
--Barrel Dragon the Machine Dragon
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If you control no monsters, you can Normal Summon this card without Tributing
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(function(e,c)
		if c==nil then return true end
		local tp=c:GetControler()
		return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end)
	c:RegisterEffect(e1)
	--During your Main Phase: You can add 1 DARK Machine monster from your Deck to your hand, except "Barrel Dragon the Machine Dragon"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--During the Battle Phase, if this card is in your GY because it was sent there from the field this turn (Quick Effect): You can Special Summon it, and if you do, toss a coin 3 times, then you can destroy monsters on the field up to the number of heads
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COIN+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		return Duel.IsBattlePhase() and c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetTurnID()==Duel.GetTurnCount()
	end)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	e3:SetHintTiming(0,TIMING_BATTLE_START|TIMING_BATTLE_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e3)
end
s.toss_coin=true
s.listed_names={id}
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_MACHINE) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,3)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local heads_count=Duel.CountHeads(Duel.TossCoin(tp,3))
		if heads_count>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)>0
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,heads_count,nil)
			if #g==0 then return end
			Duel.HintSelection(g)
			Duel.BreakEffect()
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end