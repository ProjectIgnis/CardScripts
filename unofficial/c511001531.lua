--Reincarnation of the Seven Emperors
local s,id=GetID()
function s.initial_effect(c)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	local class=c:GetMetatable(true)
	if class==nil then return false end
	local no=class.xyz_number
	return no and no>=101 and no<=107 and c:IsSetCard(0x48)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	local tco=tc:GetOverlayGroup():IsExists(s.cfilter,1,nil)
	local bco=bc:GetOverlayGroup():IsExists(s.cfilter,1,nil)
	local tcindes=false
	local bcindes=false
	if tc:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) then
		local tcind={tc:GetCardEffect(EFFECT_INDESTRUCTABLE_BATTLE)}
		for i=1,#tcind do
			local te=tcind[i]
			local f=te:GetValue()
			if type(f)=='function' then
				if f(te,bc) then tcindes=true end
			else tcindes=true end
		end
	end
	if bc:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) then
		local tcind={bc:GetCardEffect(EFFECT_INDESTRUCTABLE_BATTLE)}
		for i=1,#tcind do
			local te=tcind[i]
			local f=te:GetValue()
			if type(f)=='function' then
				if f(te,tc) then bcindes=true end
			else bcindes=true end
		end
	end
	local g=Group.CreateGroup()
	if bc~=Duel.GetAttackTarget() or bc:IsAttackPos() and tco and not tcindes then
		if bc:IsPosition(POS_FACEUP_DEFENSE) and bc==Duel.GetAttacker() then
			if bc:IsHasEffect(EFFECT_DEFENSE_ATTACK) then
				if bc:IsHasEffect(75372290) then
					if tc:IsAttackPos() then
						if bc:GetAttack()>0 and bc:GetAttack()>=tc:GetAttack() then
							g:AddCard(tc)
						end
					else
						if bc:GetAttack()>tc:GetDefense() then
							g:AddCard(tc)
						end
					end
				else
					if tc:IsAttackPos() then
						if bc:GetDefense()>0 and bc:GetDefense()>=tc:GetAttack() then
							g:AddCard(tc)
						end
					else
						if bc:GetDefense()>tc:GetDefense() then
							g:AddCard(tc)
						end
					end
				end
			end
		else
			if tc:IsAttackPos() then
				if bc:GetAttack()>0 and bc:GetAttack()>=tc:GetAttack() then
					g:AddCard(tc)
				end
			else
				if bc:GetAttack()>tc:GetDefense() then
					g:AddCard(tc)
				end
			end
		end
	end
	if tc~=Duel.GetAttackTarget() or tc:IsAttackPos() and bco and not bcindes then
		if tc:IsPosition(POS_FACEUP_DEFENSE) and tc==Duel.GetAttacker() then
			if tc:IsHasEffect(EFFECT_DEFENSE_ATTACK) then
				if tc:IsHasEffect(75372290) then
					if bc:IsAttackPos() then
						if tc:GetAttack()>0 and tc:GetAttack()>=bc:GetAttack() then
							g:AddCard(bc)
						end
					else
						if tc:GetAttack()>bc:GetDefense() then
							g:AddCard(bc)
						end
					end
				else
					if bc:IsAttackPos() then
						if tc:GetDefense()>0 and tc:GetDefense()>=bc:GetAttack() then
							g:AddCard(bc)
						end
					else
						if tc:GetDefense()>bc:GetDefense() then
							g:AddCard(bc)
						end
					end
				end
			end
		else
			if bc:IsAttackPos() then
				if tc:GetAttack()>0 and tc:GetAttack()>=bc:GetAttack() then
					g:AddCard(bc)
				end
			else
				if tc:GetAttack()>bc:GetDefense() then
					g:AddCard(bc)
				end
			end
		end
	end
	if #g==1 then
		e:SetLabelObject(g:GetFirst())
		return true
	else return false end
end
function s.filter(c,e,tp)
	return c:IsRankBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	if chk==0 then return tc and tc:IsAbleToRemove() and tc:GetOverlayGroup():IsExists(Card.IsAbleToRemove,tc:GetOverlayCount(),nil) 
		and Duel.GetLocationCountFromEx(tp,tp,tc)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	local g=tc:GetOverlayGroup()
	g:AddCard(tc)
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,tc:GetOverlayCount()+1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
		e1:SetOperation(s.damop)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_DAMAGE_STEP_END)
		e2:SetOperation(s.banop)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
		e2:SetLabelObject(tc)
		Duel.RegisterEffect(e2,tp)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e3:SetValue(1)
		e3:SetReset(RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e3)
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(tp,0)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local g=tc:GetOverlayGroup()
	g:AddCard(tc)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	local tcg=g:GetFirst()
	while tcg do
		tcg:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		tcg=g:GetNext()
	end
	if Duel.GetLocationCountFromEx(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE)
		e1:SetCountLimit(1)
		e1:SetLabelObject(g:GetFirst())
		e1:SetOperation(s.damop2)
		Duel.RegisterEffect(e1,tp)
		g:GetFirst():CreateEffectRelation(e1)
	else
		local cg=Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
		if cg and #cg>0 then
			Duel.ConfirmCards(1-tp,cg)
		end
	end
end
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.Damage(1-tp,tc:GetAttack(),REASON_EFFECT)
	end
end
