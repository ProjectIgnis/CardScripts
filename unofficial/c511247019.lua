--異次元の古戦場－サルガッソ (Anime)
--Sargasso the D.D. Battlefield (Anime)
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Register Special Summons of Xyz Monsters
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2a:SetRange(LOCATION_FZONE)
	e2a:SetCondition(s.regcon)
	e2a:SetOperation(s.regop)
	c:RegisterEffect(e2a)
	--Inflict 500 damage (Xyz Monster is Special Summoned)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetTarget(s.spsummonxyzdamtg)
	e2:SetOperation(s.spsummonxyzdamop)
	c:RegisterEffect(e2)
	--Inflict 500 damage (Player controls an Xyz monster during the End Phase)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.controlxyzdamcon)
	e3:SetOperation(s.controlxyzdamop)
	c:RegisterEffect(e3)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local d1=false
	local d2=false
	for tc in eg:Iter() do
		if tc:IsFaceup() and tc:IsMonster() and tc:IsType(TYPE_XYZ) then
			if tc:GetControler()==0 then d1=true
			else d2=true end
		end
	end
	local evt_p=PLAYER_NONE
	if d1 and d2 then evt_p=PLAYER_ALL
	elseif d1 then evt_p=0
	elseif d2 then evt_p=1 end
	e:SetLabel(evt_p)
	return evt_p~=PLAYER_NONE
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,e:GetLabel(),0)
end
function s.spsummonxyzdamtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,ep,500)
end
function s.spsummonxyzdamop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if ep==PLAYER_ALL then
		if not Duel.IsPlayerAffectedByEffect(tp,37511832) then
			Duel.Damage(tp,d,REASON_EFFECT,true)
		end
		if not Duel.IsPlayerAffectedByEffect(1-tp,37511832) then
			Duel.Damage(1-tp,d,REASON_EFFECT,true)
		end
		Duel.RDComplete()
	else
		if not Duel.IsPlayerAffectedByEffect(ep,37511832) then
			Duel.Damage(ep,d,REASON_EFFECT,true)
		end
	end
end
function s.controlxyzdamcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_XYZ),Duel.GetTurnPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.controlxyzdamop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTurnPlayer()
	if not Duel.IsPlayerAffectedByEffect(p,37511832) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.Damage(p,500,REASON_EFFECT)
	end
end