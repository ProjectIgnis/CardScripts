--ＣＸ 熱血指導神アルティメットレーナー (Anime)
--CXyz Coach Lord Ultimatrainer (Anime)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 4 Level 9 monsters
	Xyz.AddProcedure(c,nil,9,4)
	--Rank Up Check
	aux.EnableCheckRankUp(c,nil,nil,30741334)
	--Make this card become unaffected by a monster effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.uncon)
	e1:SetOperation(s.unop)
	c:RegisterEffect(e1)
	--Your opponent draws cards equal to the number of Xyz Materials detached
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(aux.bdocon)
	e2:SetCost(Cost.DetachFromSelf(1,function(e,tp) return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK) end,function(e,og) e:SetLabel(#og) end))
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_RANKUP_EFFECT)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
s.listed_names={30741334} --"Coach King Giantrainer"
function s.uncon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsActiveType(TYPE_MONSTER) then return false end
	local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_BECOME_TARGET,true)
	if res then
		if trp==tp and tre:IsActiveType(TYPE_MONSTER) and teg:IsContains(c) then
			return true
		end
	end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	if ex and tg~=nil and tg:IsContains(c) then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_TOHAND)
	if ex and tg~=nil and tg:IsContains(c) then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_REMOVE)
	if ex and tg~=nil and tg:IsContains(c) then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_TODECK)
	if ex and tg~=nil and tg:IsContains(c) then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_RELEASE)
	if ex and tg~=nil and tg:IsContains(c) then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_TOGRAVE)
	if ex and tg~=nil and tg:IsContains(c) then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_CONTROL)
	if ex and tg~=nil and tg:IsContains(c) then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DISABLE)
	if ex and tg~=nil and tg:IsContains(c) then
		return true
	end
	return false
end
function s.unop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetValue(function(e,te) return te:IsMonsterEffect() end)
		e2:SetReset(RESET_CHAIN)
		c:RegisterEffect(e2)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp,1) end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local ct=Duel.Draw(1-tp,d,REASON_EFFECT)
	if ct==0 then return end
	local dg=Duel.GetOperatedGroup()
	Duel.ConfirmCards(1-tp,dg)
	local atk=0
	local sg=Group.CreateGroup()
	local dc=dg:GetFirst()
	while dc do
		if dc:IsMonster() and dc:GetLevel()<=4 then
			local matk=dc:GetAttack()
			if matk<0 then matk=0 end
			atk=atk+matk
			sg:AddCard(dc)
		end
		dc=dg:GetNext()
	end
	Duel.Damage(1-tp,atk,REASON_EFFECT)
	Duel.BreakEffect()
	Duel.SendtoGrave(sg,REASON_EFFECT)
	Duel.ShuffleHand(1-tp)
end
