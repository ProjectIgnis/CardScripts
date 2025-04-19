--ＣＮｏ.５ 亡朧龍 カオス・キマイラ・ドラゴン (Anime)
--Number C5: Chaos Chimera Dragon (Anime)
--fixed by MLD
Duel.LoadCardScript("c69757518.lua")
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,6,3,nil,nil,Xyz.InfiniteMats)
	c:EnableReviveLimit()
	--Rank Up Check
	aux.EnableCheckRankUp(c,nil,nil,90126061)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--cannot attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetCondition(s.atcon)
	c:RegisterEffect(e2)
	--multiple attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(s.atkct)
	c:RegisterEffect(e3)
	--banish
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(Cost.Detach(1))
	e4:SetCondition(s.atkcon)
	e4:SetTarget(s.atktg)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4,false,REGISTER_FLAG_DETACH_XMAT)
	--halve atk
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetCondition(s.atkregcon)
	e5:SetOperation(s.atkregop)
	c:RegisterEffect(e5)
	--back to deck
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_TODECK)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e6:SetCountLimit(1)
	e6:SetLabelObject(e4)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTarget(s.tdtg)
	e6:SetOperation(s.tdop)
	c:RegisterEffect(e6)
	--reattach
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,2))
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCondition(s.matcon)
	e8:SetCost(s.matcost)
	e8:SetTarget(s.mattg)
	e8:SetOperation(s.matop)
	c:RegisterEffect(e8)
	--battle indestructable
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e9:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,SET_NUMBER)))
	c:RegisterEffect(e9)
	--material
	local e10=Effect.CreateEffect(c)
	e10:SetDescription(aux.Stringid(id,3))
	e10:SetType(EFFECT_TYPE_IGNITION)
	e10:SetRange(LOCATION_MZONE)
	e10:SetCountLimit(1)
	e10:SetTarget(s.ovtg)
	e10:SetOperation(s.ovop)
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_SINGLE)
	e11:SetCode(EFFECT_RANKUP_EFFECT)
	e11:SetLabelObject(e10)
	c:RegisterEffect(e11)
end
s.listed_series={SET_NUMBER}
s.listed_names={90126061}
s.xyz_number=5
function s.atkval(e,c)
	return c:GetOverlayCount()*1000
end
function s.atcon(e)
	return e:GetHandler():GetFlagEffect(id)==0
end
function s.atkct(e,c)
	return e:GetHandler():GetFlagEffect(id)-1
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and Duel.IsBattlePhase() and not e:GetHandler():IsStatus(STATUS_CHAINING)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_DECK,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_DECK,nil):RandomSelect(tp,1)
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		g:GetFirst():RegisterFlagEffect(5110205,RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END,0,0)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_BATTLE,0,0)
		end
	end
end
function s.atkregcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttackTarget()==nil
end
function s.atkregop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
	e1:SetCondition(s.halfcon)
	e1:SetValue(s.halfval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
	c:RegisterEffect(e1)
end
function s.halfcon(e)
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
end
function s.halfval(e,c)
	return math.ceil(c:GetAttack()/2)
end
function s.tdfilter(c,te)
	return c:IsAbleToDeck() and c:GetFlagEffect(5110205)~=0 and c:GetReasonEffect()==te
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local te=e:GetLabelObject()
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,0,LOCATION_REMOVED,1,nil,te) end
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,0,LOCATION_REMOVED,nil,te)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,0,LOCATION_REMOVED,nil,e:GetLabelObject())
	local ct=Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
	if ct>0 then
		Duel.SortDecktop(tp,1-tp,ct)
		g:ForEach(function(tc)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_FORBIDDEN)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_USE_AS_COST)
			tc:RegisterEffect(e2)
		end)
	end
end
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function s.matcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
function s.matfilter(c,tc,tid)
	return c:GetPreviousLocation()&LOCATION_OVERLAY~=0 and c:GetReasonEffect() and c:GetReasonEffect():GetHandler()==tc and c:GetTurnID()==tid-1
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tid=Duel.GetTurnCount()
	if Duel.IsTurnPlayer(tp) then tid=tid-1 end
	if chk==0 then return Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e:GetHandler(),tid) end
	local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e:GetHandler(),tid)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,tp,0)
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local tid=Duel.GetTurnCount()
	if Duel.IsTurnPlayer(tp) then tid=tid-1 end
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,c,tid)
	if c:IsRelateToEffect(e) then
		Duel.Overlay(c,g)
	end
end
function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND,0,1,nil) end
end
function s.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.Overlay(c,g)
	end
end