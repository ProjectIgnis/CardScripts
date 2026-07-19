--破械神雙ラギア
--Unchained Soul Rage Abominator
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2+ monsters, including a Fiend monster
	Link.AddProcedure(c,nil,2,3,s.matcheck)
	--If your opponent Special Summons a monster(s) face-up: You can target 1 of them; destroy 1 Fiend monster you control, and if you do, negate the targeted monster's effects until the end of this turn
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1a:SetCode(EVENT_CUSTOM+id)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetCountLimit(1,{id,0})
	e1a:SetTarget(s.distg)
	e1a:SetOperation(s.disop)
	e1a:SetLabelObject(Group.CreateGroup())
	c:RegisterEffect(e1a)
	--Keep track of monsters the opponent Special Summoned face-up
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1b:SetRange(LOCATION_MZONE)
	e1b:SetLabelObject(e1a)
	e1b:SetOperation(s.regop)
	c:RegisterEffect(e1b)
	--When a monster effect is activated on the field and you control a Link-4 or higher "Unchained" Link Monster (Quick Effect): You can banish this card from your GY; destroy the monster that activated that effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.descon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_UNCHAINED}
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsRace,1,nil,RACE_FIEND,lc,sumtype,tp)
end
function s.disfilter(c,e,opp)
	return c:IsSummonPlayer(opp) and c:IsNegatableMonster() and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_MZONE)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsDamageStep() then return end
	local tg=eg:Filter(s.disfilter,nil,e,1-tp)
	if #tg>0 then
		for tc in tg:Iter() do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		local g=e:GetLabelObject():GetLabelObject()
		if Duel.GetCurrentChain()==0 then g:Clear() end
		g:Merge(tg)
		g:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
		e:GetLabelObject():SetLabelObject(g)
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local opp=1-tp
	local g=e:GetLabelObject():Filter(s.disfilter,nil,e,opp)
	if chkc then return g:IsContains(chkc) and s.disfilter(chkc,e,opp) end
	local dg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsRace,RACE_FIEND),tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #dg>0 and #g>0 end
	local tc=nil
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		tc=g:Select(tp,1,1,nil):GetFirst()
	else
		tc=g:GetFirst()
	end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,tp,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsRace,RACE_FIEND),tp,LOCATION_MZONE,0,1,1,nil)
	if #g==0 then return end
	Duel.HintSelection(g)
	if Duel.Destroy(g,REASON_EFFECT)==0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		--Negate the targeted monster's effects until the end of this turn
		tc:NegateEffects(e:GetHandler(),RESET_PHASE|PHASE_END)
	end
end
function s.desconfilter(c)
	return c:IsLinkAbove(4) and c:IsSetCard(SET_UNCHAINED) and c:IsFaceup()
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsMonsterEffect() and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE and re:GetHandler():IsRelateToEffect(re)
		and Duel.IsExistingMatchingCard(s.desconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rc=re:GetHandler()
	rc:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,rc,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) then
		Duel.Destroy(rc,REASON_EFFECT)
	end
end