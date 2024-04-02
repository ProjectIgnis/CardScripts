-- ロイヤルデモンズ・ハードロック
-- Royal Rebel's Hard Rock
local s,id=GetID()
function s.initial_effect(c)
	--mat check
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetLabelObject(e0)
	e1:SetCondition(s.damcond)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsLevelAbove(7) and c:IsRace(RACE_FIEND)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local flag=0
	if g:FilterCount(s.filter,nil)==#g then flag=1 end
	e:SetLabel(flag)
end
function s.damcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN) and e:GetLabelObject():GetLabel()~=0
end
function s.damfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and not c:IsMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.damfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local sg=Duel.SelectMatchingCard(tp,s.damfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if #sg<1 then return end
	Duel.HintSelection(sg,true)
	local c=e:GetHandler()
	local atk=sg:GetFirst():GetAttack()
	if not c:IsAttack(atk) then
		Duel.Damage(1-tp,math.abs(atk-c:GetAttack()),REASON_EFFECT)
	end
	if atk>0 then
		--Increase ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
	end
end
