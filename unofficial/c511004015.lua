--Catapult Turtle (Anime)
--Scripted by Edo9300
local s,id=GetID()
function s.initial_effect(c)
	--Damage, S/T Destroy, Monster Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil)
		or Duel.CheckReleaseGroup(tp,s.filter2,1,nil,tp,e) end
	local sel=0
	if Duel.CheckReleaseGroup(tp,nil,1,nil) then
		if Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,e:GetHandler()) then
			sel=sel+2
		else
			sel=sel+1
		end
	end
	if Duel.CheckReleaseGroup(tp,s.filter2,1,nil,tp,e) then
		sel=sel+3
	end
	local op=0
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(61587183,0))
	if sel==5 then
		op=Duel.SelectOption(tp,aux.Stringid(95727991,0),aux.Stringid(24413299,2),aux.Stringid(131182,1))
	elseif sel==4 then
		op=Duel.SelectOption(tp,aux.Stringid(95727991,0),aux.Stringid(131182,1))
		if op==1 then op=2 end
	elseif sel==2 then
		op=Duel.SelectOption(tp,aux.Stringid(95727991,0),aux.Stringid(24413299,2))
	elseif sel==3 then
		Duel.SelectOption(tp,aux.Stringid(131182,1))
		op=2
	elseif sel==1 then
		Duel.SelectOption(tp,aux.Stringid(95727991,0))
		op=0
	end
	if op==0 or op==1 then
		sg=Duel.SelectReleaseGroup(tp,nil,1,1,nil)		
	elseif op==2 then
		sg=Duel.SelectReleaseGroup(tp,s.filter2,1,1,nil,tp,e)
	end
	if op==0 then
		e:SetCategory(CATEGORY_DAMAGE)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e:SetTarget(s.target)
		e:SetOperation(s.operation)
		e:SetLabel(sg:GetFirst():GetAttack()/2)
	elseif op==1 then
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_PLAYER_TARGET)
		e:SetTarget(s.target2)
		e:SetOperation(s.operation2)
		e:SetLabelObject(sg:GetFirst())
	elseif op==2 then
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_PLAYER_TARGET)
		e:SetTarget(s.target3)
		e:SetOperation(s.operation3)
		Duel.SetTargetCard(sg)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(600)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sg:GetFirst():RegisterEffect(e1)
		e:SetLabel(sg:GetFirst():GetAttack())
	end
	Duel.Release(sg,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.filter(c)
	return c:IsDestructable() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup()
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(e:GetLabelObject():GetOwner())
	Duel.SetTargetParam(e:GetLabelObject():GetAttack()/2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabelObject():GetAttack()/2)
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			Duel.Damage(p,d,REASON_EFFECT)
		end
	end
end
function s.filter2(c,tp,e)
	return Duel.IsExistingTarget(s.filter3,tp,0,LOCATION_MZONE,1,nil,c:GetAttack()+600) and c:IsReleasableByEffect() and c:IsCanBeEffectTarget(e)
end
function s.filter3(c,atk)
	return c:IsDestructable() and c:GetDefense()<atk
end
function s.target3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=Duel.GetFirstTarget()
	Duel.SetTargetPlayer(tc:GetOwner())
	Duel.SetTargetParam(tc:GetTextAttack()/2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.filter3,tp,0,LOCATION_MZONE,1,1,nil,e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,tc:GetTextAttack()/2)
end
function s.operation3(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			Duel.Damage(p,d,REASON_EFFECT)
		end
	end
end
