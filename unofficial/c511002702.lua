--オッドアイズ・ファントム・ドラゴン (Manga)
--Odd-Eyes Phantom Dragon (Manga)
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--summon success
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.regcon)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	-- damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	--atk
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetRange(LOCATION_PZONE)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
s.listed_series={0x99}
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_PENDULUM
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~(RESET_TEMP_REMOVE|RESET_TURN_SET)|RESET_PHASE+PHASE_END,0,1)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0 and ep~=tp
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local atk=Duel.GetFieldGroup(tp,LOCATION_PZONE,0):GetSum(Card.GetAttack)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Damage(p,atk,REASON_EFFECT)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local c=e:GetHandler()
	local pc=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	if pc==c then pc=Duel.GetFieldCard(tp,LOCATION_PZONE,1) end
	if not pc or not pc:IsSetCard(SET_ODD_EYES) or not a or not d then return end
	local atk=pc:GetAttack()
	if atk<=0 then return end
	local g=Group.FromCards(a,d)
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_CARD,0,id)
		local sg=g:FilterSelect(tp,Card.IsFaceup,1,1,nil)
		local tc=sg:GetFirst()
		Duel.HintSelection(sg)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
	end
end