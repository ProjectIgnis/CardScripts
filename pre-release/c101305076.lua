--道化の一座『終演』
--Clown Crew "Finale"
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--If you control a Tribute Summoned monster: Discard any number of cards, then target that many face-up cards on the field; destroy them
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(Card.IsTributeSummoned,tp,LOCATION_MZONE,0,1,nil) end)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetCountLimit(1,{id,0})
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--You can banish this card from your GY and Tribute 1 Ritual, Fusion, Synchro, Xyz, Pendulum, or Link Monster from your hand or field; add 1 "Clown Crew" monster from your Deck or GY to your hand with a different original Level/Rank/Link Rating than the Tributed monster's
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(Cost.AND(Cost.SelfBanish,s.thcost))
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	e2:SetCountLimit(1,{id,1})
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
s.listed_series={SET_CLOWN_CREW}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-1)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	local max_target_count=Duel.GetTargetCount(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	local discard_count=Duel.DiscardHand(tp,nil,1,max_target_count,REASON_COST|REASON_DISCARD,nil)
	e:SetLabel(discard_count)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() and chkc~=c end
	if chk==0 then
		local cost_chk=e:GetLabel()==-1
		e:SetLabel(0)
		return cost_chk and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
	end
	local target_count=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tg=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,target_count,target_count,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,#tg,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
function s.rating(c)
	if c:IsLinkMonster() then return c:GetLink()
	elseif c:IsXyzMonster() then return c:GetOriginalRank()
	else return c:GetOriginalLevel() end
end
function s.thcostfilter(c,tp)
	return c:IsType(TYPE_RITUAL|TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_PENDULUM|TYPE_LINK)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,s.rating(c))
end
function s.thfilter(c,lv)
	return c:IsSetCard(SET_CLOWN_CREW) and c:IsMonster() and c:IsAbleToHand() and s.rating(c)~=lv
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-1)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.thcostfilter,1,1,true,nil,nil,tp) end
	local sc=Duel.SelectReleaseGroupCost(tp,s.thcostfilter,1,1,true,nil,nil,tp):GetFirst()
	Duel.Release(sc,REASON_COST)
	e:SetLabel(s.rating(sc))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local cost_chk=e:GetLabel()==-1
		e:SetLabel(0)
		return cost_chk
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e:GetLabel()):GetFirst()
	if sc then
		if sc:IsLocation(LOCATION_GRAVE) then Duel.HintSelection(sc) end
		Duel.SendtoHand(sc,nil,REASON_EFFECT)
		if sc:IsPreviousLocation(LOCATION_DECK) then Duel.ConfirmCards(1-tp,sc) end
	end
end