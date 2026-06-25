--朽ちた祭儀要録
--Corrupted Ritual Records
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Reveal 1 Ritual Spell in your hand or Deck, and add 1 monster that mentions it from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--If a face-up Ritual Monster(s) you control leaves the field by card effect while this card is in your GY, and you control no face-up non-Ritual Monsters: You can add this card to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.selfthcon)
	e2:SetTarget(s.selfthtg)
	e2:SetOperation(s.selfthop)
	c:RegisterEffect(e2)
end
function s.revealfilter(c,tp)
	return c:IsRitualSpell() and not c:IsPublic() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
function s.thfilter(c,code)
	return c:IsMonster() and c:ListsCode(code) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.revealfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.rescon(sg,e,tp,mg)
	local ritual_spell=sg:Filter(Card.IsRitualSpell,nil):GetFirst()
	return ritual_spell and sg:IsExists(s.thfilter,1,nil,ritual_spell:GetCode()),not ritual_spell
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.revealfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil,tp)
	if #g==0 then return end
	g:Merge(Duel.GetMatchingGroup(aux.AND(Card.IsMonster,Card.IsAbleToHand),tp,LOCATION_DECK,0,nil))
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,aux.Stringid(id,2))
	if #sg==2 then
		local opp=1-tp
		local ritual_spell,monster=sg:Split(Card.IsRitualSpell,nil)
		Duel.ConfirmCards(opp,ritual_spell)
		Duel.SendtoHand(monster,nil,REASON_EFFECT)
		Duel.ConfirmCards(opp,monster)
	end
end
function s.selfthconfilter(c,tp)
	return c:IsRitualMonster() and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsReason(REASON_EFFECT)
end
function s.selfthcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.selfthconfilter,1,nil,tp)
end
function s.selfthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
		and not Duel.IsExistingMatchingCard(aux.FaceupFilter(aux.NOT(Card.IsRitualMonster)),tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.selfthop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end