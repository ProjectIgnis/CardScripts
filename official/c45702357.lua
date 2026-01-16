--リバーシブル・ビートル
--Reversible Beetle
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Shuffle this card, also any face-up monsters in its column, into the Deck(s)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	--Change this card, also any monsters in its column, to face-down Defense Position
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_POSITION+CATEGORY_SET)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2a:SetCode(EVENT_SUMMON_SUCCESS)
	e2a:SetCountLimit(1,{id,1})
	e2a:SetTarget(s.postg)
	e2a:SetOperation(s.posop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local colg=c:GetColumnGroup():Match(aux.AND(Card.IsMonster,Card.IsFaceup),nil)
	if not c:IsStatus(STATUS_BATTLE_DESTROYED) then colg:AddCard(c) end
	if #colg>0 then
		Duel.SendtoDeck(colg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,PLAYER_ALL,POS_FACEDOWN_DEFENSE)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local colg=c:GetColumnGroup():Match(aux.AND(Card.IsMonster,Card.IsFaceup),nil)+c
	if #colg>0 then
		Duel.ChangePosition(colg,POS_FACEDOWN_DEFENSE)
	end
end