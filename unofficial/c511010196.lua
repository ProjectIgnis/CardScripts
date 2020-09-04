--ＣＮｏ.９６ ブラック・ストーム (Anime)
--Number C96: Dark Storm (Anime)
--fixed by MLD
Duel.LoadScript("rankup_functions.lua")
Duel.LoadCardScript("c77205367.lua")
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),3,4)
	c:EnableReviveLimit()
	--Rank Up Check
	aux.EnableCheckRankUp(c,nil,nil,55727845)
	--battle indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,0x48)))
	c:RegisterEffect(e1)
	--damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	--atk
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(s.atkcost)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	e3:SetLabel(RESET_EVENT+RESETS_STANDARD)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_RANKUP_EFFECT)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4,false,REGISTER_FLAG_DETACH_XMAT)
end
s.listed_series={0x48}
s.listed_names={55727845}
s.xyz_number=96
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return bc and bc:GetAttack()>0 and c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_PHASE+PHASE_DAMAGE,0,0)
	Duel.SetTargetCard(bc)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetAttack()>0 then
		local atk=tc:GetAttack()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(atk)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not c:IsHasEffect(EFFECT_TO_GRAVE_REDIRECT) and bc then
		if c:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) then
			local tcind={c:GetCardEffect(EFFECT_INDESTRUCTABLE_BATTLE)}
			for i=1,#tcind do
				local te=tcind[i]
				local f=te:GetValue()
				if type(f)=='function' then
					if f(te,bc) then return end
				else return end
			end
		end
		local a=Duel.GetAttacker()
		local d=Duel.GetAttackTarget()
		local chk=false
		if d~=c then a,d=d,a end
		if a:IsPosition(POS_FACEUP_DEFENSE) then
			if not a:IsHasEffect(EFFECT_DEFENSE_ATTACK) then return end
			if a:IsHasEffect(75372290) then
				if d:IsAttackPos() then
					if a:GetDefense()==d:GetAttack() then
						chk=a:GetDefense()~=0
					else
						chk=a:GetDefense()>=d:GetAttack()
					end
				else
					chk=a:GetDefense()>d:GetDefense()
				end
			else
				if d:IsAttackPos() then
					if a:GetAttack()==d:GetAttack() then
						chk=a:GetAttack()~=0
					else
						chk=a:GetAttack()>=d:GetAttack()
					end
				else
					chk=a:GetAttack()>d:GetDefense()
				end
			end
		else
			if d:IsAttackPos() then
				if a:GetAttack()==d:GetAttack() then
					chk=a:GetAttack()~=0
				else
					chk=a:GetAttack()>=d:GetAttack()
				end
			else
				chk=a:GetAttack()>d:GetDefense()
			end
		end
		if chk then
			Duel.ChangeBattleDamage(1-ep,ev,false)
		end
	end
end
