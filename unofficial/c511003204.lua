--女帝の冠 (Anime)
--Empress's Crown (Anime)
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_SPSUMMON,TIMING_SPSUMMON+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.actcon)
	e2:SetDescription(aux.Stringid(id,0))
	c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsType,TYPE_SYNCHRO),tp,0,LOCATION_MZONE,nil)*2
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsType,TYPE_SYNCHRO),tp,0,LOCATION_MZONE,nil)*2
	Duel.Draw(p,ct,REASON_EFFECT)
end
function s.cfilter(c,p)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsControler(p)
end
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
	if res then
		return teg:IsExists(s.cfilter,1,nil,1-tp)
	end
end