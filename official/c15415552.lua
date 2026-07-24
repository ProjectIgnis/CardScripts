--JP name
--Mortilux Heruvur
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2+ Level 8 monsters
	Xyz.AddProcedure(c,nil,8,2,nil,nil,Xyz.InfiniteMats)
	--If a monster(s) is sent to your opponent's GY (except during the Damage Step): You can target 1 of them; attach it to this card. You can only use this effect of "Mortilux Heruvur" once per turn
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1a:SetCode(EVENT_CUSTOM+id)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetCountLimit(1,id)
	e1a:SetTarget(s.attachtg)
	e1a:SetOperation(s.attachop)
	e1a:SetLabelObject(Group.CreateGroup())
	c:RegisterEffect(e1a)
	--Keep track of monsters sent to the opponent's GY
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1b:SetCode(EVENT_TO_GRAVE)
	e1b:SetRange(LOCATION_MZONE)
	e1b:SetLabelObject(e1a)
	e1b:SetOperation(s.regop)
	c:RegisterEffect(e1b)
	--This card gains effects based on the number of materials attached to it
	--● 2+: Cannot be destroyed by battle or card effects
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_SINGLE)
	e2a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2a:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetCondition(s.xyzmatcountcon(2))
	e2a:SetValue(1)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2b)
	--● 3+: Your opponent cannot target cards in the GYs with card effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
	e3:SetCondition(s.xyzmatcountcon(3))
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	--● 4+: You can detach 3 materials from this card; send 1 monster on the field to the GY
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.xyzmatcountcon(4))
	e4:SetCost(Cost.DetachFromSelf(3))
	e4:SetTarget(s.sendtogytg)
	e4:SetOperation(s.sendtogyop)
	c:RegisterEffect(e4)
end
function s.attachfilter(c,tp,e,xyzc)
	return c:IsLocation(LOCATION_GRAVE) and c:IsMonster() and c:IsControler(1-tp)
		and c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT) and c:IsCanBeEffectTarget(e)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsDamageStep() then return end
	local c=e:GetHandler()
	local tg=eg:Filter(s.attachfilter,nil,tp,e,c)
	if #tg>0 then
		for tc in tg:Iter() do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		local g=e:GetLabelObject():GetLabelObject()
		if Duel.GetCurrentChain()==0 then g:Clear() end
		g:Merge(tg)
		g:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
		e:GetLabelObject():SetLabelObject(g)
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=e:GetLabelObject():Filter(s.attachfilter,nil,tp,e,c)
	if chkc then return g:IsContains(chkc) and s.attachfilter(chkc,tp,e,c) end
	if chk==0 then return c:IsXyzMonster() and #g>0 end
	local tc=nil
	if #g==1 then
		tc=g:GetFirst()
		Duel.SetTargetCard(tc)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
		tc=g:Select(tp,1,1,nil)
		Duel.SetTargetCard(tc)
	end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,tp,0)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsCanBeXyzMaterial(c,tp,REASON_EFFECT) then
		Duel.Overlay(c,tc)
	end
end
function s.xyzmatcountcon(required)
	return function(e)
		return e:GetHandler():GetOverlayCount()>=required
	end
end
function s.sendtogytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,tp,0)
end
function s.sendtogyop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end