--魔界劇場「ファンタスティックシアター」
--Abyss Playhouse – Fantastic Theater
--Scripted by ahtelel
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Search 1 "Abyss Script" Spell
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Change a monster effect to "Destroy 1 Set Spell/Trap your opponent controls"
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.chcon1)
	e3:SetOperation(s.chop1)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ABYSS_ACTOR,SET_ABYSS_SCRIPT}
function s.cfilter(c)
	return c:IsSetCard(SET_ABYSS_ACTOR) and c:IsType(TYPE_PENDULUM) and not c:IsPublic()
end
function s.cfilter2(c,tp)
	return c:IsSetCard(SET_ABYSS_SCRIPT) and c:IsSpell() and not c:IsPublic()
		and Duel.IsExistingMatchingCard(s.cfilter3,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
function s.cfilter3(c,code)
	return c:IsSetCard(SET_ABYSS_SCRIPT) and c:IsSpell() and not c:IsCode(code) and c:IsAbleToHand()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g1=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	local g2=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_HAND,0,1,1,nil,tp)
	e:SetLabel(g2:GetFirst():GetCode())
	g1:Merge(g2)
	Duel.ConfirmCards(1-tp,g1)
	Duel.ShuffleHand(tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.cfilter3,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.chcon1(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsMonsterEffect()
		and Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.chop1(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
end
function s.confilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_ABYSS_ACTOR) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
function s.desfilter(c)
	return c:IsFacedown() and c:IsSpellTrap()
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g,true)
		Duel.Destroy(g,REASON_EFFECT)
	end
end