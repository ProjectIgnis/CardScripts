--ダークネス・トランザム・クライシス
--Darkness Transam Craisis
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Summon with 3 tribute
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.nscondition)
	e1:SetTarget(s.nstarget)
	e1:SetOperation(s.nsoperation)
	e1:SetValue(SUMMON_TYPE_TRIBUTE+1)
	c:RegisterEffect(e1)
	--Destroy 1 card your opponent controls
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:GetClassCount(Card.GetAttribute,nil)==1
		and (#sg==3 or (#sg==2 and sg:IsExists(Card.HasFlagEffect,1,nil,FLAG_HAS_DOUBLE_TRIBUTE)) or (#sg==1 and sg:IsExists(Card.HasFlagEffect,1,nil,160015135)))
end
function s.nscondition(e)
	local c=e:GetHandler()
	local tp=c:GetControler()
	local mg=Duel.GetTributeGroup(c)
	return #mg>=1 and aux.SelectUnselectGroup(mg,e,tp,1,3,s.rescon,0)
end
function s.nstarget(e,tp,eg,ep,ev,re,r,rp,chk,c,minc,zone,relzone,exeff)
	local mg=Duel.GetTributeGroup(c)
	local g=aux.SelectUnselectGroup(mg,e,tp,1,3,nil,1,tp,HINTMSG_TRIBUTE,s.rescon,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.nsoperation(e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	Duel.Release(g,REASON_SUMMON|REASON_MATERIAL)
	g:DeleteGroup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_TRIBUTE+1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNotMaximumModeSide,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,200)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.SelectMatchingCard(tp,Card.IsNotMaximumModeSide,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #dg>0 then
		dg=dg:AddMaximumCheck()
		Duel.HintSelection(dg,true)
		if Duel.Destroy(dg,REASON_EFFECT)>0 and dg:GetFirst():IsMonster() and dg:GetFirst():GetLevel()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			local atk=dg:GetFirst():GetLevel()*200
			if dg:GetFirst():WasMaximumMode() then
				atk=dg:Filter(Card.WasMaximumModeCenter,nil):GetFirst():GetLevel()*200
			end
			local c=e:GetHandler()
			-- Gain 200 ATK x the level of the destroyed monster
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
			e1:SetValue(atk)
			c:RegisterEffect(e1)
		end
	end
end