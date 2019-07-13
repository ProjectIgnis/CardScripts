--Battleguard Mad Shaman
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17132130,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetValue(1)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--control
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(s.ctcon)
	e3:SetTarget(s.cttg)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
	--cannot be battle target
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e4:SetCondition(s.con)
	e4:SetValue(aux.imval1)
	c:RegisterEffect(e4)
	--switch
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_CONTROL)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetTarget(s.swtg)
	e5:SetOperation(s.swop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e6)
	local e7=e5:Clone()
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e7)
	--control
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_CONTROL_CHANGED)
	e8:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e8:SetRange(LOCATION_MZONE)
	e8:SetOperation(s.conop)
	c:RegisterEffect(e8)
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:IsExists(Card.IsBattleguard,1,nil)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetReleaseGroup(tp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-3 and #rg>2 and rg:IsExists(Card.IsBattleguard,1,nil) 
		and aux.SelectUnselectGroup(rg,e,tp,3,3,s.rescon,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetReleaseGroup(tp)
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,1,tp,HINTMSG_RELEASE)
	Duel.Release(sg,REASON_COST)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetCardTarget()
	return not g:IsExists(Card.IsControler,1,nil,tp)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if Duel.GetControl(tc,tp) then
			if c:GetFlagEffect(id)==0 then
				c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_SET_CONTROL)
				e1:SetRange(LOCATION_MZONE)
				e1:SetTargetRange(LOCATION_MZONE,0)
				e1:SetTarget(s.cttg2)
				e1:SetValue(s.ctval)
				c:RegisterEffect(e1)
			end
			c:SetCardTarget(tc)
		end
	end
end
function s.ctval(e,c)
	return e:GetHandlerPlayer()
end
function s.cttg2(e,c)
	return e:GetHandler():IsHasCardTarget(c)
end
function s.filter(c,e)
	return e:GetHandler():IsHasCardTarget(c)
end
function s.con(e)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(s.filter,c:GetControler(),LOCATION_MZONE,0,1,c,e)
end
function s.swfilter(c,tp,atk)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsSummonPlayer(1-tp)
		and c:GetAttack()>atk
end
function s.swtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetHandler():GetCardTarget():Filter(Card.IsControler,nil,tp):GetFirst()
	if not g then return false end
	local atk=g:GetAttack()
	if chk==0 then return eg:IsExists(s.swfilter,1,nil,tp,atk) end
	local g2=eg:Filter(s.swfilter,nil,tp,atk)
	if #g2>0 then
		if #g2>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
			g2=g2:Select(tp,1,1,nil)
		end
	end
	g2:AddCard(g)
	Duel.SetTargetCard(g2)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g2,2,0,0)
end
function s.swop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	g=g:Filter(Card.IsRelateToEffect,nil,e)
	local g1=g:GetFirst()
	local g2=g:GetNext()
	if g1:IsControler(1-tp) then g1,g2=g2,g1 end
	if #g>1 then
		Duel.SwapControl(g1,g2,0,0)
		e:GetHandler():SetCardTarget(g2)
	end
end
function s.conop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetCardTarget():Filter(Card.IsControler,nil,tp)
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local des=g:Select(tp,1,1,nil)
		Duel.Destroy(des,REASON_EFFECT)
	end
end
