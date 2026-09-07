--N・グロー・モス (Anime)
--Neo-Spacian Glow Moss (Anime)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return e:GetHandler()==Duel.GetAttacker() or e:GetHandler()==Duel.GetAttackTarget() end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:HasFlagEffect(id) end
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE,0,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)==0 then
		Duel.DiscardDeck(tp,2,REASON_EFFECT)
		return
	end
	Duel.ConfirmDecktop(1-tp,1)
	local tc=Duel.GetDecktopGroup(1-tp,1):GetFirst()
	if Duel.IsPlayerCanDraw(1-tp,1) and Duel.SelectYesNo(1-tp,aux.Stringid(id,0)) then
		Duel.Draw(1-tp,1,REASON_EFFECT)
	else
		Duel.DiscardDeck(tp,2,REASON_EFFECT)
	end
	local c=e:GetHandler()
	if tc:IsSpell() then
        if Duel.GetAttacker()==c and not c:IsHasEffect(EFFECT_CANNOT_DIRECT_ATTACK)
            and c:IsRelateToEffect(e) and c:IsFaceup() and Duel.SelectYesNo(tp,aux.Stringid(17732278,1)) then
            Duel.ChangeAttackTarget(nil)
        end
	elseif tc:IsMonster() then
		Duel.GetAttacker():SetStatus(STATUS_ATTACK_CANCELED,true)
		c:ResetFlagEffect(id)
	else
		if c:IsRelateToEffect(e) and c:IsAttackPos() then
			Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		end
	end
	Duel.ShuffleHand(1-tp)
end
