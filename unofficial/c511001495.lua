--シャイニング・スライ
--Shining Sly
local s,id=GetID()
function s.initial_effect(c)
	--cannot be battle target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(s.atcon)
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	--Negate Damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.cost)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.atcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_XYZ),0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.specialchk(sg,tp,exg,opG)
	return not opG or #(opG-sg)>0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
		if not ex or not cp or Duel.IsPlayerAffectedByEffect(cp,EFFECT_REVERSE_DAMAGE) then
			ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_RECOVER)
			if not ex or not cp or not Duel.IsPlayerAffectedByEffect(cp,EFFECT_REVERSE_RECOVER) then return false end
		end
		local opTribute=Duel.GetMatchingGroup(Card.IsReleasable,tp,0,LOCATION_MZONE,nil)
		local tpTribute=Duel.CheckReleaseGroupCost(tp,nil,1,false,s.specialchk,nil,cp==PLAYER_ALL and opTribute)
		return cp==tp and tpTribute or cp==1-tp and #opTribute>0 or tpTribute and #opTribute>0
	end
	local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
	if not ex or not cp or Duel.IsPlayerAffectedByEffect(cp,EFFECT_REVERSE_DAMAGE) then
		ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_RECOVER)
	end
	Duel.SetTargetPlayer(cp)
	local opG=(cp==1-tp or cp==PLAYER_ALL) and Duel.SelectMatchingCard(tp,Card.IsReleasable,tp,0,LOCATION_MZONE,1,1,nil) or Group.CreateGroup()
	local tpG=(cp==tp or cp==PLAYER_ALL) and Duel.SelectReleaseGroupCost(tp,nil,1,1,false,s.specialchk,nil,cp==PLAYER_ALL and opG) or Group.CreateGroup()
	Duel.Release(tpG+opG,REASON_COST)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,val,r,rc)
	local cid,cp=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID,CHAININFO_TARGET_PLAYER)
	if not cp then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange((cp==tp or cp==PLAYER_ALL) and 1 or 0,(cp==1-tp or cp==PLAYER_ALL) and 1 or 0)
	e1:SetLabel(cid)
	e1:SetValue(s.refcon)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
end
function s.refcon(e,re,val,r,rp,rc)
	local cc=Duel.GetCurrentChain()
	if cc==0 or (r&REASON_EFFECT)==0 then return val end
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid==e:GetLabel() then return 0 else return val end
end