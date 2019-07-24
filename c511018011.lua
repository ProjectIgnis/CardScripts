--Dark Contract with Underworld Insurance
--cleaned up by MLD
local s,id=GetID()
function s.initial_effect(c)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		s[0]=Group.CreateGroup()
		s[1]=Group.CreateGroup()
		s[0]:KeepAlive()
		s[1]:KeepAlive()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE_STEP_END)
		ge1:SetOperation(s.chkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetCountLimit(1)
		ge2:SetOperation(s.clearop)
		Duel.RegisterEffect(ge2,0)
	end)
end
function s.chkop(e,tp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not d then return end
	if a:IsControler(tp) and d:IsRelateToBattle() and d:IsLocation(LOCATION_MZONE) then
		s[tp]:AddCard(d)
	elseif a:IsControler(1-tp) and d:IsRelateToBattle() and d:IsLocation(LOCATION_MZONE) then
		s[1-tp]:AddCard(d)
	end
end
function s.clearop()
	s[0]:Clear()
	s[1]:Clear()
end
function s.condition(e,tp,eg,ev,ep,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN2 and Duel.GetTurnPlayer()==tp
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=s[tp]
	local ct=#g
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
