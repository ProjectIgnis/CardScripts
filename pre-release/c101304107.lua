--クリムゾン・ヘルコール
--Crimson Call
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 Level 4 or lower Fiend monster from your GY to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Allow your "/Assault Mode" monster or "Red Dragon Archfiend" to make a second attack in a row
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.atkcon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetOperation(function() Duel.ChainAttack() end)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_RED_DRAGON_ARCHFIEND}
s.listed_series={SET_ASSAULT_MODE}
function s.thfilter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_FIEND) and c:IsAbleToHand()
end
function s.rdafilter(c)
	return (c:IsCode(CARD_RED_DRAGON_ARCHFIEND) or (c:IsSynchroMonster() and c:ListsCode(CARD_RED_DRAGON_ARCHFIEND))) and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local locations=Duel.IsExistingMatchingCard(s.rdafilter,tp,LOCATION_MZONE,0,1,nil) and LOCATION_GRAVE|LOCATION_DECK or LOCATION_GRAVE 
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,locations,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,locations)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local locations=Duel.IsExistingMatchingCard(s.rdafilter,tp,LOCATION_MZONE,0,1,nil) and LOCATION_GRAVE|LOCATION_DECK or LOCATION_GRAVE 
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,locations,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetAttacker()
	return ac:IsControler(tp) and ac:CanChainAttack() and (ac:IsCode(CARD_RED_DRAGON_ARCHFIEND) or c:IsSetCard(SET_ASSAULT_MODE))
end