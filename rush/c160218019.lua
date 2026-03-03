--霊術の指南書
--Handbook to the Spiritual Arts
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Excavate and destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.filter(c)
	return c:IsMonster() and c:IsRace(RACE_SPELLCASTER) and c:IsAttack(500,1900) and c:IsDefense(1500)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<5 then return end
	Duel.ConfirmDecktop(tp,5)
	local g=Duel.GetDecktopGroup(tp,5)
	Duel.DisableShuffleCheck()
	local exg=g:Filter(s.filter,nil)
	local dg=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,0,LOCATION_ONFIELD,nil)
	local ct=math.min(#exg//2,#dg)
	if ct>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=dg:Select(tp,1,ct,nil)
		local sg2=sg:AddMaximumCheck()
		if #sg>0 then
			Duel.HintSelection(sg2)
			if Duel.Destroy(sg,REASON_EFFECT)==2 then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetTargetRange(LOCATION_MZONE,0)
				e1:SetTargetRange(LOCATION_MZONE,0)
				e1:SetCondition(s.atkcon)
				e1:SetTarget(s.atktg)
				e1:SetReset(RESET_PHASE|PHASE_END)
				Duel.RegisterEffect(e1,tp)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetCode(EVENT_ATTACK_ANNOUNCE)
				e2:SetOperation(s.checkop)
				e2:SetReset(RESET_PHASE|PHASE_END)
				e2:SetLabelObject(e1)
				Duel.RegisterEffect(e2,tp)
			end
		end
	end
	local ct2=#g
	if ct2>0 then
		Duel.MoveToDeckBottom(ct2,tp)
		Duel.SortDeckbottom(tp,tp,ct2)
	end
end
function s.atkcon(e)
	return e:GetLabel()~=0
end
function s.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetAttackTarget()
	if tg==nil then	
		local fid=eg:GetFirst():GetFieldID()
		e:GetLabelObject():SetLabel(fid)
	end
end