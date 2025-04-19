-- 花牙シノビ・ガトリング
--Gatling the Shadow Flower Shinobi
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 2 of opponent's monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.costfilter(c)
	return c:IsMonster() and c:IsType(TYPE_NORMAL) and c:IsRace(RACE_PLANT) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,2,nil) end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,LOCATION_MZONE)
end
function s.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsLevelBelow(8) and not c:IsMaximumModeSide()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,2,2,nil)
	if Duel.SendtoGrave(tg,REASON_COST)==2 then
		--Effect
		local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			sg=g:Select(tp,1,2,nil)
			local dam=500*#sg
			sg=sg:AddMaximumCheck()
			if Duel.Destroy(sg,REASON_EFFECT)>0 then
				local ct=Duel.GetOperatedGroup():FilterCount(s.damfilter,nil,tp)
				Duel.Damage(1-tp,500*ct,REASON_EFFECT)
			end
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
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
function s.damfilter(c,tp)
	return not c:IsMaximumModeSide()
end
function s.atkcon(e)
	return e:GetLabel()~=0
end
function s.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local fid=eg:GetFirst():GetFieldID()
	e:GetLabelObject():SetLabel(fid)
end
