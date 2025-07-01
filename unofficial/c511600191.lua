--エクシーズ・ウイング
--XYZ Wings
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsType,TYPE_XYZ))
	--You can activate the equipped monster's "once per turn" effects that are activated by detaching its own Xyz Material(s) once again per turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(id)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
	--Inflict 500 damage to your opponent
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	--Any battle damage you take becomes halved
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(s.bdop)
	c:RegisterEffect(e3)
end
s.affected_effects={}
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsHasEffect(id)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	--affect the effects of Xyz monsters that are equipped
	local xg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	for xc in xg:Iter() do
		for _,eff in ipairs({xc:GetOwnEffects()}) do
			local usect,ctmax,ctcode,ctflag,hopt=eff:GetCountLimit()
			if eff:HasDetachCost() and not eff:IsHasProperty(EFFECT_FLAG_NO_TURN_RESET)
				and ctmax==1 and (ctflag&~EFFECT_COUNT_CODE_SINGLE)==0
				and not s.affected_effects[eff] then
				eff:SetCountLimit(2,{ctcode,hopt},ctflag)
				if usect==0 then eff:UseCountLimit(eff:GetHandlerPlayer()) end
				s.affected_effects[eff]=true
			end
		end
	end
	--stop affecting effects that are no longer applicable
	for eff in pairs(s.affected_effects) do
		if not eff:HasDetachCost() or not xg:IsContains(eff:GetHandler()) then
			local usect,_,ctcode,ctflag,hopt=eff:GetCountLimit()
			eff:SetCountLimit(1,{ctcode,hopt},ctflag)
			if usect<2 then eff:UseCountLimit(eff:GetHandlerPlayer()) end
			s.affected_effects[eff]=nil
		end
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and eg:IsContains(ec)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.bdop(e,tp,eg,ep,ev,re,r,rp)
	--For the rest of this turn, any battle damage you take becomes halved
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(_,_,dam,r) return (r&REASON_BATTLE)~=0 and (dam//2) or dam end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
