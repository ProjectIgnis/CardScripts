--あないみじや玉の緒ふたつ
--Tragic Twin Twined Jewels
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Equip only to a monster you control that was Special Summoned from the Extra Deck
	aux.AddEquipProcedure(c,0,aux.FilterBoolFunction(Card.IsSummonLocation,LOCATION_EXTRA))
	--Destroy it, also the equipped monster, and if you do, take damage equal to the total original ATK of the destroyed monsters, then inflict damage to your opponent equal to the damage you took
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.desconfilter(c,tp,atk)
	return c:IsSummonPlayer(1-tp) and c:IsSummonLocation(LOCATION_EXTRA) and c:GetAttack()>atk
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and eg:IsExists(s.desconfilter,1,nil,tp,ec:GetAttack())
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ec=e:GetHandler():GetEquipTarget()
	local g=eg:Filter(s.desconfilter,nil,tp,ec:GetAttack()):Match(Card.IsCanBeEffectTarget,nil,e)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return #g>0 end
	local tg=nil
	if #g==1 then
		tg=g
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		tg=g:Select(tp,1,1,nil)
	end
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg+ec,2,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,tg:GetSum(Card.GetBaseAttack))
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local g=Group.FromCards(e:GetHandler():GetEquipTarget())
	if tc:IsRelateToEffect(e) then
		g:AddCard(tc)
	end
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		local dam=Duel.GetOperatedGroup():GetSum(Card.GetBaseAttack)
		if dam==0 then return end
		local val=Duel.Damage(tp,dam,REASON_EFFECT)
		if val>0 then
			Duel.BreakEffect()
			Duel.Damage(1-tp,val,REASON_EFFECT)
		end
	end
end