--捨て身の宝札
--Card of Sacrifice (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		--Keep track of manual position changing
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHANGE_POS)
		ge1:SetOperation(s.poscheck)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.poscheck(e,tp,eg,ep,ev,re,r,rp)
	if re==nil then
		Duel.RegisterFlagEffect(rp,id,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.check(tp)
	local sg=Duel.GetMatchingGroup(Card.IsPosition,tp,LOCATION_MZONE,0,nil,POS_FACEUP_ATTACK)
	if #sg==0 then return false end
	local og=Duel.GetMatchingGroup(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_FACEUP_ATTACK)
	if #og==0 then return false end
	local atk1=sg:GetSum(Card.GetAttack)
	local _,atk2=og:GetMinGroup(Card.GetAttack)
	return atk1<atk2
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return s.check(tp)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SUMMON)==0
		and Duel.GetActivityCount(tp,ACTIVITY_FLIPSUMMON)==0
		and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0
		and Duel.GetFlagEffect(tp,id)==0 end
	local c=e:GetHandler()
	--Cannot Summon monsters this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	Duel.RegisterEffect(e3,tp)
	--Cannot change the battle positions of monsters
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_OATH)
	e4:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e4:SetReset(RESET_PHASE+PHASE_END)
	e4:SetTargetRange(LOCATION_MZONE,0)
	Duel.RegisterEffect(e4,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not s.check(tp) then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end