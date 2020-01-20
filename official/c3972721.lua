--グリード・グラード
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local p1=false
	local p2=false
	for tc in aux.Next(eg) do
		if tc:IsType(TYPE_SYNCHRO) and tc:IsPreviousLocation(LOCATION_MZONE)
			and ((tc:IsReason(REASON_BATTLE) and (tc:GetBattlePosition()&POS_FACEUP)~=0)
			or (not tc:IsReason(REASON_BATTLE) and tc:IsPreviousPosition(POS_FACEUP)))
			and tc:GetPreviousControler()~=tc:GetReasonPlayer() then
				if tc:GetReasonPlayer()==0 then
					p1=true
				else
					p2=true
				end
		end
	end
	if p1 then Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1) end
	if p2 then Duel.RegisterFlagEffect(1,id,RESET_PHASE+PHASE_END,0,1) end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)~=0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
