--ＢＫ チート・コミッショナー (Anime)
--Battlin' Boxer Cheat Commissioner (Anime)
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	--Change battle position/attack target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e,tp) return Duel.GetBattleMonster(tp)==e:GetHandler() end)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	--Detach to end BP and activate Spell Card
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_CONFIRM)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanChangePosition,0,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(Card.IsCanChangePosition,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,#sg,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	local g=Duel.GetMatchingGroup(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.ChangePosition(g,POS_FACEUP_ATTACK)
		Duel.BreakEffect()
		if Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,c) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			if a==c and at then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACK)
				local sc=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,c):GetFirst()
				Duel.ChangeAttacker(sc)
			elseif at and at==c then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACKTARGET)
				local sc=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,c):GetFirst()
				Duel.ChangeAttackTarget(sc)
			end
		end
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetAttacker()~=c and Duel.GetAttackTarget() and Duel.GetAttackTarget()~=c
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	Duel.SendtoGrave(c:GetOverlayGroup(),REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
end
function s.filter(c,tp,eg,ep,ev,re,r,rp)
	local te=c:GetActivateEffect()
	if not te then return false end
	if c:IsHasEffect(EFFECT_CANNOT_TRIGGER) then return false end
	local pre={Duel.GetPlayerEffect(tp,EFFECT_CANNOT_ACTIVATE)}
	if pre[1] then
		for i,eff in ipairs(pre) do
			local prev=eff:GetValue()
			if type(prev)~='function' or prev(eff,te,tp) then return false end
		end
	end
	local condition=te:GetCondition()
	local cost=te:GetCost()
	local target=te:GetTarget()
	return c:IsSpell() and (not condition or condition(te,tp,eg,ep,ev,re,r,rp)) and (not cost or cost(te,tp,eg,ep,ev,re,r,rp,0))
		and (not target or target(te,tp,eg,ep,ev,re,r,rp,0)) and (c:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #hg>0 then
		Duel.ConfirmCards(1-tp,hg)
		local spg=hg:Filter(s.filter,nil,tp,eg,ep,ev,re,r,rp)
		if #spg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
			local tc=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_HAND,1,1,nil,tp,eg,ep,ev,re,r,rp):GetFirst()
			Duel.SetTargetCard(tc)
			if not tc or (tc:IsHasEffect(EFFECT_CANNOT_TRIGGER) or tc:IsForbidden()) then return end
			Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
			Duel.BreakEffect()
			local tpe=tc:GetType()
			local te=tc:GetActivateEffect()
			if not te then return end
			local pre={Duel.GetPlayerEffect(tp,EFFECT_CANNOT_ACTIVATE)}
			if pre[1] then
				for i,eff in ipairs(pre) do
					local prev=eff:GetValue()
					if type(prev)~='function' or prev(eff,te,tp) then return false end
				end
			end
			local con=te:GetCondition()
			local co=te:GetCost()
			local tg=te:GetTarget()
			local op=te:GetOperation()
			if (not con or con(te,tp,eg,ep,ev,re,r,rp)) and (not co or co(te,tp,eg,ep,ev,re,r,rp,0)) and (not tg or tg(te,tp,eg,ep,ev,re,r,rp,0)) then
				Duel.ClearTargetCard()
				e:SetCategory(te:GetCategory())
				e:SetProperty(te:GetProperty())
				local loc=LOCATION_SZONE
				if (tpe&TYPE_FIELD)~=0 then
					loc=LOCATION_FZONE
					local fc=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)
					if Duel.IsDuelType(DUEL_1_FIELD) then
						if fc then
							Duel.Destroy(fc,REASON_RULE)
						end
						fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
						if fc and Duel.Destroy(fc,REASON_RULE)==0 then
							Duel.SendtoGrave(tc,REASON_RULE)
						end
					else
						fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
						if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then
							Duel.SendtoGrave(tc,REASON_RULE)
						end
					end
				end
				Duel.MoveToField(tc,tp,tp,loc,POS_FACEUP,true)
				Duel.Hint(HINT_CARD,0,tc:GetCode())
				tc:CreateEffectRelation(te)
				if (tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 and not tc:IsHasEffect(EFFECT_REMAIN_FIELD) then
					tc:CancelToGrave(false)
				end
				if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
				if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
				local sg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
				if sg then
					local etc=sg:GetFirst()
					while etc do
						etc:CreateEffectRelation(te)
						etc=sg:GetNext()
					end
				end
				Duel.BreakEffect()
				if op then op(te,tp,eg,ep,ev,re,r,rp) end
				tc:ReleaseEffectRelation(te)
				if etc then
					etc=sg:GetFirst()
					while etc do
						etc:ReleaseEffectRelation(te)
						etc=sg:GetNext()
					end
				end
			end
		end
	end
end