-- 死製棺サルコファガス
-- Entombing Casket Sarcophagus
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Take control when self is destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.ctcon)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	-- Take control when another Zombie is destroyed by battle
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.gctcon)
	e2:SetCost(aux.bfgcost)
	c:RegisterEffect(e2)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabelObject(e:GetHandler())
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsStatus(STATUS_OPPO_BATTLE) and bc and bc:IsAbleToChangeControler()
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject():GetReasonCard()
	if chk==0 then return tc:IsRelateToBattle() end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local dc=e:GetLabelObject()
	if not dc then return end
	local tc=dc:GetBattleTarget()
	if tc and tc:IsControler(1-tp) and Duel.GetControl(tc,tp) then
		-- Treat as Zombie
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_ZOMBIE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- ATK/DEF becomes 0
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetValue(0)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e3)
	end
end
function s.ctconfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:GetPreviousRaceOnField()&RACE_ZOMBIE~=0 and c:IsStatus(STATUS_OPPO_BATTLE)
		and c:GetBattleTarget():IsAbleToChangeControler()
end
function s.gctcon(e,tp,eg,ep,ev,re,r,rp)
	if not eg or eg:IsContains(e:GetHandler()) then return false end
	local g=eg:Filter(s.ctconfilter,nil,tp)
	e:SetLabelObject(g:GetFirst())
	return #g>0
end