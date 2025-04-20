--Ｒｅｃｅｔｔｅｓ ｄｅ Ｎｏｕｖｅｌｌｅｚ～ヌーベルズのレシピ帳～
--Nouvelles Recipe Book "Recettes de Nouvellez"
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e0)
	--While you control a "Nouvelles" Monster Card, all face-up monsters your opponent controls are changed to Attack Position
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_POSITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(s.atkposcon)
	e1:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e1)
	--Each time a monster(s) is Tributed by a Ritual Monster's effect, your opponent pays 850 LP
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.lpcon)
	e2:SetOperation(s.lpop)
	c:RegisterEffect(e2)
	--Add 1 "Recipe" or "Nouvelles" card from your Deck to your hand, except a Continuous Spell, and if you do, increase the target's Level by 1
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,1))
	e3a:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_LVCHANGE)
	e3a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3a:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3a:SetCode(EVENT_CUSTOM+id+1)
	e3a:SetRange(LOCATION_SZONE)
	e3a:SetCountLimit(1)
	e3a:SetCondition(function() return not Duel.IsPhase(PHASE_DAMAGE) end)
	e3a:SetTarget(s.thtg)
	e3a:SetOperation(s.thop)
	c:RegisterEffect(e3a)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e3a:SetLabelObject(g)
	--Register your Special Summoned Ritual monsters
	local e3b=Effect.CreateEffect(c)
	e3b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3b:SetRange(LOCATION_SZONE)
	e3b:SetLabelObject(e3a)
	e3b:SetOperation(s.regsumop)
	c:RegisterEffect(e3b)
end
s.listed_seris={SET_NOUVELLES,SET_RECIPE}
function s.nouvfilter(c)
	return c:IsSetCard(SET_NOUVELLES) and c:IsMonsterCard() and c:IsFaceup()
end
function s.atkposcon(e)
	return Duel.IsExistingMatchingCard(s.nouvfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsMonsterEffect() and re:GetHandler():IsRitualMonster()
		and r&REASON_EFFECT>0 and eg:IsExists(Card.IsMonster,1,nil)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CheckLPCost(1-tp,850) then
		Duel.Hint(HINT_CARD,1-tp,id)
		Duel.PayLPCost(1-tp,850)
	end
end
function s.lvfilter(c,e,tp)
	return c:IsRitualMonster() and c:IsSummonPlayer(tp) and c:IsFaceup()
		and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_MZONE) and c:HasLevel()
end
function s.thfilter(c)
	return c:IsSetCard({SET_RECIPE,SET_NOUVELLES}) and not c:IsContinuousSpell() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=e:GetLabelObject():Filter(s.lvfilter,nil,e,tp)
	if chkc then return g:IsContains(chkc) and s.lvfilter(chkc,e,tp) end
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)  end
	local tc=nil
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		tc=g:Select(tp,1,1,nil):GetFirst()
	else
		tc=g:GetFirst()
	end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,tc,1,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if sc and Duel.SendtoHand(sc,nil,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,sc)
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			--Increase that monster's Level by 1
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
function s.regsumop(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(s.lvfilter,nil,e,tp)
	if #tg>0 then
		for tc in tg:Iter() do
			tc:RegisterFlagEffect(id+1,RESET_CHAIN,0,1)
		end
		local g=e:GetLabelObject():GetLabelObject()
		if Duel.GetCurrentChain()==0 then g:Clear() end
		g:Merge(tg)
		g:Remove(function(c) return c:GetFlagEffect(id+1)==0 end,nil)
		e:GetLabelObject():SetLabelObject(g)
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id+1,e,0,tp,tp,0)
	end
end