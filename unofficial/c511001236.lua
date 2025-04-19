--モンスターレジスター
--Monster Register
--Fixed by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_DRAW_PHASE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ex,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_SUMMON_SUCCESS,true)
	if not ex then
		ex,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
		if not ex then
			ex,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_FLIP_SUMMON_SUCCESS,true)
		end
	end
	if ex and s.target(e,tp,teg,tep,tev,tre,tr,trp,0) then
		e:SetCategory(CATEGORY_DECKDES)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e:SetOperation(s.activate)
		s.target(e,tp,teg,tep,tev,tre,tr,trp,1)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
function s.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) or (c:IsPreviousControler(tp) and c:GetPreviousPosition()==POS_FACEUP_ATTACK 
	or c:GetPreviousPosition()==POS_FACEUP_DEFENSE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	local tg=eg:Filter(Card.IsFaceup,nil)
	Duel.SetTargetCard(tg)
	local b1=tg:IsExists(s.filter,1,nil,tp)
	local b2=tg:IsExists(s.filter,1,nil,1-tp)
	local p=b1 and b2 and PLAYER_ALL or b1 and tp or 1-tp
	Duel.SetTargetPlayer(p)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,p,tg:GetSum(Card.GetLevel))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tg=Duel.GetTargetCards(e)
	local g1=tg:Filter(s.filter,nil,tp)
	local g2=tg:Filter(s.filter,nil,1-tp)
	local lv1=g1:GetSum(Card.GetLevel)
	local lv2=g2:GetSum(Card.GetLevel)
	if #g1>0 and lv1>0 then
		Duel.DiscardDeck(tp,lv1,REASON_EFFECT)
	end
	if #g2>0 and lv2>0 then
		Duel.DiscardDeck(1-tp,lv2,REASON_EFFECT)
	end
end