--霊体化の鍛錬
--Spiritualization Training
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Add appropriate cards
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={id}
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsCode(id) then
		Duel.RegisterFlagEffect(rp,id,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.HasFlagEffect(tp,id)
end
function s.revfilter(c,tp)
	return c:IsMonster() and not c:IsPublic() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,c:GetAttribute())
end
function s.charmerfil(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttack(500,1900) and c:IsDefense(1500)
end
function s.familiarfil(c)
	return c:IsLevel(4) and c:IsAttack(1500) and c:IsDefense(200)
end
function s.thfilter(c,att)
	return (s.charmerfil(c) or s.familiarfil(c)) and c:IsAttribute(att) and c:IsAbleToHand()
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetAttribute)==1 and sg:FilterCount(s.charmerfil,nil)<2 and sg:FilterCount(s.familiarfil,nil)<2
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.revfilter,tp,LOCATION_HAND,0,nil,tp)
		return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local g=Duel.GetMatchingGroup(s.revfilter,tp,LOCATION_HAND,0,nil,tp)
	local td=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_CONFIRM)
	local att=td:GetFirst():GetAttribute()
	Duel.ConfirmCards(1-tp,td)
	Duel.ShuffleHand(tp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil,att)
	local tg=aux.SelectUnselectGroup(sg,1,tp,1,2,s.rescon,1,tp)
	local ct=Duel.SendtoHand(tg,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tg)
end