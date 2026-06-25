--JP name
--Rustin Mammoth
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--If this card is in your hand: You can banish Machine Link Monsters from your Extra Deck whose combined Link Ratings equal exactly 5; Special Summon this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--You can target 1 card you control and 1 card your opponent controls; return them to the hand
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_TOHAND)
	e2a:SetType(EFFECT_TYPE_IGNITION)
	e2a:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetCountLimit(1,{id,1})
	e2a:SetCondition(aux.NOT(s.rthquickcon))
	e2a:SetTarget(s.rthtg)
	e2a:SetOperation(s.rthop)
	c:RegisterEffect(e2a)
	--This is a Quick Effect if this card is linked to a Link-3 or higher Machine Link Monster
	local e2b=e2a:Clone()
	e2b:SetType(EFFECT_TYPE_QUICK_O)
	e2b:SetCode(EVENT_FREE_CHAIN)
	e2b:SetCondition(s.rthquickcon)
	e2b:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2b)
end
function s.spcostfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsLinkMonster() and c:IsAbleToRemoveAsCost()
end
function s.rescon(sg,e,tp,mg)
	return sg:GetSum(Card.GetLink)==5
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return #g>0 and aux.SelectUnselectGroup(g,e,tp,1,5,s.rescon,0) end
	local rg=aux.SelectUnselectGroup(g,e,tp,1,5,s.rescon,1,tp,HINTMSG_REMOVE,s.rescon)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,0)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetTargetGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetControler),0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetControler),1,tp,HINTMSG_RTOHAND)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,2,tp,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
function s.rthquickconfilter(c,ec,lg)
	return c:IsLinkAbove(3) and c:IsRace(RACE_MACHINE) and c:IsFaceup() and (c:GetLinkedGroup():IsContains(ec) or lg:IsContains(c))
end
function s.rthquickcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(s.rthquickconfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c,c:GetLinkedGroup())
end