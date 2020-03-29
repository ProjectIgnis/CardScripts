--機甲部隊の再編制
--Machina Reformation
--Scripted by Eerie code
local s,id=GetID()
function s.initial_effect(c)
	--activate (option 1)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost(s.cfilter1))
	e1:SetTarget(s.target(s.filter1))
	e1:SetOperation(s.activate(s.filter1))
	c:RegisterEffect(e1)
	--activate (option 2)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCost(s.cost(s.cfilter2))
	e2:SetTarget(s.target(s.filter2))
	e2:SetOperation(s.activate(s.filter2))
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={0x36}
function s.cfilter1(c)
	return c:IsDiscardable()
end
function s.cfilter2(c)
	return s.cfilter1(c) and c:IsSetCard(0x36)
end
function s.filter1(c)
	return c:IsSetCard(0x36) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.filter2(c)
	return c:IsSetCard(0x36) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.cost(cfil)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.IsExistingMatchingCard(cfil,tp,LOCATION_HAND,0,1,e:GetHandler()) end
				Duel.DiscardHand(tp,cfil,1,1,REASON_COST+REASON_DISCARD)
			end
end
function s.target(fil)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local g=Duel.GetMatchingGroup(fil,tp,LOCATION_DECK,0,nil)
				if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,0) end
				Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
			end
end
function s.activate(fil)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local g=Duel.GetMatchingGroup(fil,tp,LOCATION_DECK,0,nil)
				local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_ATOHAND)
				if #sg==2 then
					Duel.SendtoHand(sg,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,sg)
				end
			end
end
