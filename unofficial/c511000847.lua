--希望のかけら
--Shard of Hope
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetTarget(s.tg)
	c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_BATTLE_DAMAGE,true)
	if res and s.drcon(e,tp,teg,tep,tev,tre,tr,trp) and s.drtg(e,tp,teg,tep,tev,tre,tr,trp,0) then
		e:SetOperation(s.drop)
		s.drtg(e,tp,teg,tep,tev,tre,tr,trp,1)
		e:SetCategory(CATEGORY_DRAW)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	else
		e:SetOperation(nil)
		e:SetCategory(0)
		e:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	end
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local chain=Duel.GetCurrentChain()-1
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local h=Duel.GetDecktopGroup(tp,1)
	local tc=h:GetFirst()
	Duel.Draw(p,d,REASON_EFFECT)
	if tc then
		Duel.ConfirmCards(1-tp,tc)
		local te=tc:GetActivateEffect()
		if te and tc:IsTrap() then
			local chk=true
			local pre={Duel.GetPlayerEffect(tp,EFFECT_CANNOT_ACTIVATE)}
			if pre[1] then
				for i,eff in ipairs(pre) do
					local prev=eff:GetValue()
					if type(prev)~='function' or prev(eff,te,tp) then chk=false end
				end
			end
			if chk and tc:CheckActivateEffect(false,false,false)~=nil and not tc:IsHasEffect(EFFECT_CANNOT_TRIGGER) then
				Duel.Destroy(e:GetHandler(),REASON_EFFECT)
				local tpe=tc:GetType()
				local tg=te:GetTarget()
				local co=te:GetCost()
				local op=te:GetOperation()
				e:SetCategory(te:GetCategory())
				e:SetProperty(te:GetProperty())
				Duel.ClearTargetCard()
				local loc=LOCATION_SZONE
				if (tpe&TYPE_FIELD)~=0 then
					loc=LOCATION_FZONE
					local fc=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)
					if Duel.IsDuelType(DUEL_1_FIELD) then
						if fc then Duel.Destroy(fc,REASON_RULE) end
						fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
						if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
					else
						fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
						if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
					end
				end
				Duel.MoveToField(tc,tp,tp,loc,POS_FACEUP,true)
				if (tpe&TYPE_TRAP+TYPE_FIELD)==TYPE_TRAP+TYPE_FIELD then
					Duel.MoveSequence(tc,5)
				end
				Duel.Hint(HINT_CARD,0,tc:GetCode())
				tc:CreateEffectRelation(te)
				if (tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 and not tc:IsHasEffect(EFFECT_REMAIN_FIELD) then
					tc:CancelToGrave(false)
				end
				if te:GetCode()==EVENT_CHAINING then
					local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
					local tc=te2:GetHandler()
					local g=Group.FromCards(tc)
					local p=tc:GetControler()
					if co then co(te,tp,g,p,chain,te2,REASON_EFFECT,p,1) end
					if tg then tg(te,tp,g,p,chain,te2,REASON_EFFECT,p,1) end
				elseif te:GetCode()==EVENT_FREE_CHAIN then
					if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
					if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
				else
					local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
					if co then co(te,tp,teg,tep,tev,tre,tr,trp,1) end
					if tg then tg(te,tp,teg,tep,tev,tre,tr,trp,1) end
				end
				Duel.BreakEffect()
				local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
				if g then
					local etc=g:GetFirst()
					while etc do
						etc:CreateEffectRelation(te)
						etc=g:GetNext()
					end
				end
				tc:SetStatus(STATUS_ACTIVATED,true)
				if not tc:IsDisabled() then
					if te:GetCode()==EVENT_CHAINING then
						local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
						local tc=te2:GetHandler()
						local g=Group.FromCards(tc)
						local p=tc:GetControler()
						if op then op(te,tp,g,p,chain,te2,REASON_EFFECT,p) end
					elseif te:GetCode()==EVENT_FREE_CHAIN then
						if op then op(te,tp,eg,ep,ev,re,r,rp) end
					else
						local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
						if op then op(te,tp,teg,tep,tev,tre,tr,trp) end
					end
				else
					--insert negated animation here
				end
				Duel.RaiseEvent(Group.CreateGroup(tc),EVENT_CHAIN_SOLVED,te,0,tp,tp,Duel.GetCurrentChain())
				if g and tc:IsType(TYPE_EQUIP) and not tc:GetEquipTarget() then
					Duel.Equip(tp,tc,g:GetFirst())
				end
				tc:ReleaseEffectRelation(te)
				if etc then
					etc=g:GetFirst()
					while etc do
						etc:ReleaseEffectRelation(te)
						etc=g:GetNext()
					end
				end
				return
			end
		end
		Duel.Destroy(tc,REASON_EFFECT)
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end