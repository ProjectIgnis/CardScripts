--終刻起動『Ｄ．Ｏ．Ｏ．Ｍ．Ｄ．Ｕ．Ｒ．Ｇ．』
--Doom-Z Command "D.O.O.M.D.U.R.G"
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Inflict 500 damage to the equipped monster's controller during the Standby Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e) return e:GetHandler():GetEquipTarget() end)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
	--Your opponent cannot target this card with card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetValue(aux.tgoval)
	--Destroy 1 other face-up card you control, also this card gains ATK equal to its own Level/Rank x 100, it can attack directly and if it battles destroy it at the end of the Damage Step
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP|TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e3:SetCondition(aux.StatChangeDamageStepCondition)
	e3:SetTarget(s.desatktg)
	e3:SetOperation(s.desatkop)
	--Grant the above effects to a "Doom-Z" monster equipped with this card
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(function(e,c) return e:GetHandler():GetEquipTarget()==c and c:IsSetCard(SET_DOOM_Z) end)
	e4:SetLabelObject(e2)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetLabelObject(e3)
	c:RegisterEffect(e5)
	--Grant the above protection effect (e2) to a WIND Machine Xyz Monster that has it as material
	local e6=e2:Clone()
	e6:SetType(EFFECT_TYPE_XMATERIAL)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e6)
	--Grant the above destruction+atk change effect (e3) to a WIND Machine Xyz Monster that has it as material
	local e7=e3:Clone()
	e7:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(function(e) local c=e:GetHandler() return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_MACHINE) end)
	c:RegisterEffect(e7)
end
s.listed_series={SET_DOOM_Z}
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local p=e:GetHandler():GetEquipTarget():GetControler()
	Duel.SetTargetPlayer(p)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,1,p,500)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(e:GetHandler():GetEquipTarget():GetControler(),500,REASON_EFFECT)
end
function s.desatktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local dg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,c)
	if chk==0 then return #dg>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,tp,0)
	local atk=(c:HasLevel() and c:GetLevel() or c:GetRank())*100
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,atk)
end
function s.desatkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local exc=c:IsRelateToEffect(e) and c or nil
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local desg=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,exc)
	if #desg==0 then return end
	Duel.HintSelection(desg)
	if Duel.Destroy(desg,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		if c:IsFaceup() then
			local atk=(c:HasLevel() and c:GetLevel() or c:GetRank())*100
			--This card gains ATK equal to its own Level/Rank x 100
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
			c:RegisterEffect(e1)
		end
		--It can attack directly
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,2))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_DIRECT_ATTACK)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e2)
		--If it battles, destroy it at the end of the Damage Step
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_DAMAGE_STEP_END)
		e3:SetCondition(function(e) return e:GetHandler():IsRelateToBattle() end)
		e3:SetOperation(function(e) Duel.Hint(HINT_CARD,0,c:GetOriginalCodeRule()) Duel.Destroy(e:GetHandler(),REASON_EFFECT) end)
		e3:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e3)
	end
end