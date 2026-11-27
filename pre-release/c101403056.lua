--無死なる竜の鼓動
--Reindsurm Carnation
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--While you control a "Reindsurm" monster whose original Level is 8 or higher or your opponent has a Dragon monster in their field or GY, the activated effects of your "Reindsurm" monsters cannot be negated
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DISEFFECT)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(s.cannotdiscon)
	e1:SetValue(s.cannotdisfilter)
	c:RegisterEffect(e1)
	--Once per turn: You can send 1 "Reindsurm" monster or Dragon monster from your hand or face-up field to the GY; add 1 Insect monster from your Deck to your hand with the same original Level, but a different original name
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_REINDSURM}
function s.cannotdisconfilter(c,tp)
	return (c:IsSetCard(SET_REINDSURM) and c:GetOriginalLevel()>=8 and c:IsFaceup() and c:IsControler(tp))
		or (c:IsRace(RACE_DRAGON) and c:IsFaceup() and c:IsControler(1-tp))
end
function s.cannotdiscon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.cannotdisconfilter,tp,LOCATION_MZONE,LOCATION_MZONE|LOCATION_GRAVE,1,nil,tp)
end
function s.cannotdisfilter(e,ct)
	return Chain.IsTriggeringPlayer(ct,e:GetHandlerPlayer())
		and Chain.IsTriggeringSetcode(ct,SET_REINDSURM)
		and Chain.IsTriggeringType(ct,TYPE_MONSTER)
end
function s.thcostfilter(c,tp)
	return (c:IsSetCard(SET_REINDSURM) or c:IsRace(RACE_DRAGON)) and c:IsMonster() and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetOriginalLevel(),c:GetOriginalCodeRule())
end
function s.thfilter(c,cost_level,cost_name)
	return c:IsRace(RACE_INSECT) and c:IsOriginalLevel(cost_level) and not c:IsOriginalCodeRule(cost_name) and c:IsAbleToHand()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thcostfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=Duel.SelectMatchingCard(tp,s.thcostfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	Duel.SendtoGrave(sc,REASON_COST)
	local cd=e:GetChainData()
	cd.cost_level=sc:GetOriginalLevel()
	cd.cost_name=sc:GetOriginalCodeRule()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local cd=e:GetChainData()
	local cost_level=cd.cost_level
	local cost_name=cd.cost_name
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,cost_level,cost_name)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end