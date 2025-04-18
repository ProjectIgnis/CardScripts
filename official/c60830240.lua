--熾動する煉獄
--Void Reignition
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Discard entire hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.dccost)
	e1:SetTarget(s.dctg)
	e1:SetOperation(s.dcop)
	c:RegisterEffect(e1)
	--Return up to 11 banished "Infernoid" monsters to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(s.tgcon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_INFERNOID,SET_VOID}
function s.dccostfilter(c)
	return not c:IsPublic()
		and ((c:IsSetCard(SET_INFERNOID) and c:IsMonster())
		or (c:IsSetCard(SET_VOID) and c:IsSpellTrap()))
end
function s.dccost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.dccostfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.dccostfilter,tp,LOCATION_HAND,0,1,1,c)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function s.dctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)-e:GetHandler()
	local ct=#g
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,g,ct,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.dcop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if #g==0 then return end
	local ct=Duel.SendtoGrave(g,REASON_EFFECT|REASON_DISCARD)
	if ct>0 and Duel.IsPlayerCanDraw(tp) then
		Duel.BreakEffect()
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.exccon(e,tp,eg,ep,ev,re,r,rp)
		and not Duel.IsExistingMatchingCard(aux.NOT(aux.FaceupFilter(Card.IsRace,RACE_FIEND)),tp,LOCATION_MZONE,0,1,nil)
end
function s.tgfilter(c,e)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(SET_INFERNOID) and c:IsCanBeEffectTarget(e)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_REMOVED,0,nil,e)
	if chk==0 then return #g>0 end
	local tg=aux.SelectUnselectGroup(g,e,tp,1,11,aux.dncheck,1,tp,aux.Stringid(id,2))
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tg,#tg,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT|REASON_RETURN)
	end
end