--ドリル・アームド・ドラゴン
--Drill Armed Dragon
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Apply a "for the rest of this turn, all WIND Dragon monsters you control will gain 300 ATK" effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.atkcost)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--Add 1 Dragon monster from your Deck to your hand with a Level equal to the number of banished monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
function s.atkcostfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToGraveAsCost()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(s.atkcostfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.atkcostfilter,tp,LOCATION_HAND,0,1,1,c)
	Duel.SendtoGrave(g+c,REASON_COST)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	--For the rest of this turn, all WIND Dragon monsters you control will gain 300 ATK
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_DRAGON) end)
	e1:SetValue(300)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.thcostfilter(c)
	return c:IsRace(RACE_DRAGON) and (c:IsLevelAbove(7) or c:IsAttribute(ATTRIBUTE_WIND)) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.rescon(sg,e,tp,mg)
	return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,#sg)
end
function s.thfilter(c,lv)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(lv) and not c:IsCode(id)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	local rg=Duel.GetMatchingGroup(s.thcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(rg,e,tp,1,#rg,s.rescon,0) end
	local g=aux.SelectUnselectGroup(rg,e,tp,1,#rg,s.rescon,1,tp,HINTMSG_REMOVE)
	e:SetLabel(#g)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then local res=e:GetLabel()==-100 e:SetLabel(0) return res end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end